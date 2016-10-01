CREATE OR REPLACE VIEW range_type AS
    SELECT
            rngtypid::regtype AS range_type, rtn.nspname AS range_type_schema, rt.typname AS range_type_name
            , rngsubtype::regtype AS range_subtype, stn.nspname AS range_subtype_schema, st.typname AS range_subtype_name
            , rngcollation AS range_type_collation_oid, cn.nspname AS range_type_collation_schema, c.collname AS range_type_collation_name
            , rngsubopc AS range_type_operator_class_oid, oc.opcname AS range_type_operator_class_name, ocn.nspname AS range_type_operator_class_schema
            , rngcanonical AS range_type_canonical_function
            , rngsubdiff::regprocedure AS range_type_subdiff_function
        FROM pg_range r
            LEFT JOIN pg_type rt ON rt.oid = rngtypid
            LEFT JOIN pg_namespace rtn ON rtn.oid = rt.typnamespace
            LEFT JOIN pg_type st ON st.oid = rngsubtype
            LEFT JOIN pg_namespace stn ON stn.oid = st.typnamespace
            LEFT JOIN pg_collation c ON c.oid = rngcollation
            LEFT JOIN pg_namespace cn ON cn.oid = c.collnamespace
            LEFT JOIN pg_opclass oc ON oc.oid = rngsubopc
            LEFT JOIN pg_namespace ocn ON ocn.oid = oc.opcnamespace
;

create function to_range(range anyrange, low anyelement, high anyelement, bounds text DEFAULT '[)') returns anyrange
language plpgsql immutable as $$
declare
    l_range text;
begin
    execute format('select %s($1,$2,$3)',pg_typeof(range)) using low, high, bounds into l_range;
    return l_range;
end
$$;

comment on function to_range(range anyrange, low anyelement, high anyelement, bounds text)
is E'Given a lower bound, upper bound, bounds description, return a range of the given range type.';

create function to_range(range anyrange, elem anyelement) returns anyrange
language sql immutable set search_path from current as $$
select to_range(range,elem,elem,'[]');
$$;

comment on function to_range(range anyrange, elem anyelement)
is E'Convert an element e into the range [e].';

create function element_range_comp(range anyrange, element anyelement) returns smallint
language sql strict immutable set search_path from current as $$
select  case
            when to_range(range,element) << range then -1::smallint
            when to_range(range,element) <@ range then 0::smallint
            when to_range(range,element) >> range then 1::smallint
        end;
$$;

comment on function element_range_comp(anyrange, anyelement)
is E'Perform a strcmp-like comparison of an element and a range type.\n'
    'Return 0 if the element is within the range.\n'
    'Return -1 if the element is below the lower bound of the range.\n'
    'Return 1 if the element is above the upper bound of the range.\n';

create function is_singleton(range anyrange) returns boolean
language sql immutable set search_path from current as $$
select range is not distinct from to_range(range,lower(range));
--select lower_inc(range) and upper_inc(range) and lower(range) = upper(range);
$$;

comment on function is_singleton(range anyrange)
is E'Returns true if the range has only one possible element.';


create function get_collation_expr(range anyrange) returns text
language sql stable set search_path from current as $$
select  ' COLLATE "' || l.collname::text || '"'
from    pg_range r
join    pg_collation l
on      l.oid = r.rngcollation
where   r.rngtypid = pg_typeof(range);
$$;

comment on function get_collation_expr(range anyrange)
is 'return COLLATE "foo" or null';

create function get_subtype_element_expr(range anyrange, placeholder text default 'x') returns text
language sql stable set search_path from current as $$
select  placeholder || coalesce(get_collation_expr(range),'');
$$;

comment on function get_subtype_element_expr(range anyrange, placeholder text)
is 'express a valid subtype by name with proper collation';

create function get_bound_expr(range anyrange, literal anyelement) returns text
language sql stable set search_path from current as $$
select  format('%L::%s%s',literal,format_type(rngsubtype,null), get_collation_expr(range))
from    pg_range
where   rngtypid = pg_typeof(range);
$$;

comment on function get_bound_expr(range anyrange, literal anyelement)
is E'express a value casted as the subtype of the given range';

create function get_lower_bound_condition_expr(range anyrange, placeholder text default 'x') returns text
language sql immutable set search_path from current as $$
select  case
            when lower_inf(range) then 'true'
            when isempty(range) then 'false'
            when lower_inc(range) then format('%s >= %s',
                                                get_subtype_element_expr(range,placeholder),
                                                get_bound_expr(range,lower(range)))
            else format('%s > %s',
                        get_subtype_element_expr(range,placeholder),
                        get_bound_expr(range,lower(range)))
        end;
$$;

comment on function get_lower_bound_condition_expr(anyrange,text)
is E'Given a range and a placeholder value, construct the where-clause fragment for the lower bound of the range\n';

create function get_upper_bound_condition_expr(range anyrange, placeholder text default 'x') returns text
language sql immutable set search_path from current as $$
select  case
            when upper_inf(range) then 'true'
            when isempty(range) then 'false'
            when upper_inc(range) then format('%s <= %s',
                                                get_subtype_element_expr(range,placeholder),
                                                get_bound_expr(range,upper(range)))
            else format('%s < %s',
                        get_subtype_element_expr(range,placeholder),
                        get_bound_expr(range,upper(range)))
        end;
$$;

comment on function get_upper_bound_condition_expr(anyrange,text)
is E'Given a range and a placeholder value, construct the where-clause fragment for the upper bound of the range';

create function get_bounds_condition_expr(range anyrange, placeholder text default 'x') returns text
language sql immutable set search_path from current as $$
select  case
            when lower(range) = upper(range) then format('%s = %L',placeholder,lower(range))
            when isempty(range) then 'false'
            when lower_inf(range) and upper_inf(range) then 'true'
            when lower_inf(range) then get_upper_bound_condition_expr(range,placeholder)
            when upper_inf(range) then get_lower_bound_condition_expr(range,placeholder)
            else format('%s and %s',
                        get_lower_bound_condition_expr(range,placeholder),
                        get_upper_bound_condition_expr(range,placeholder))
        end;
$$;

comment on function get_bounds_condition_expr(anyrange,text)
is E'Given a range and a placeholder value, construct the where-clause fragment for the range';


-- grant execute on all functions in this extension to public
do $$
declare r record;
begin
    for r in (  select	p.proname, pg_get_function_identity_arguments(p.oid) as args
                from	pg_proc p
                join	pg_depend d on d.objid = p.oid and d.deptype = 'e'
                join	pg_extension x on x.oid = d.refobjid
                where   x.extname = 'range_type_functions' )
    loop
        execute format('grant execute on function %s(%s) to public',r.proname,r.args);
    end loop;
end
$$;

CREATE OR REPLACE FUNCTION _range_from_array__create(
    range_type regtype
) RETURNS regprocedure LANGUAGE plpgsql
SET search_path FROM CURRENT -- This is necessary for having access to the range_type view
-- Do NOT set search_path here! Function needs to run with the calling search_path
AS $_range_from_array__create$
DECLARE
    subtype regtype;

    /*
    * THIS IS INTENTIONALLY regproc! Using regproc ensures we get an error if
    * the function isn't unique.
    */
    creation_function regproc;

    c_template CONSTANT text := $template$
-- This is a template!
CREATE OR REPLACE FUNCTION range_from_array(
    a %2$s[] -- 2:range_subtype
) RETURNS %1$s -- 1:range_type
LANGUAGE sql IMMUTABLE STRICT
SET search_path FROM CURRENT -- Make sure search path is same as when creation function was called
AS $range_from_array$
SELECT %3$s( -- 3:creation_function
          min(u)
          , max(u)
          , '[]'
        )
    FROM unnest(a) u
$range_from_array$;
$template$;
  
    sql text;
BEGIN
    SELECT INTO subtype, creation_function
            range_subtype
                , format(
                $$%1$s(%2$s, %2$s, text)$$
                , t.range_type -- Blindly assume function has same name as the range type
                , range_subtype
            )::regprocedure::oid -- Note that this gets cast back to regproc. Cast to OID is mandatory for 9.4
        FROM range_type t
        WHERE t.range_type = _range_from_array__create.range_type
    ;
    IF NOT FOUND THEN
        /*
         * Since range_type is of type regtype it must be a valid type, but it
         * might not be a range type. If we get here either it's not a range type
         * or our view is broken. :)
         */
        RAISE 'type "%" is not a range type', range_type
          USING ERRCODE = 'undefined_object'
        ;
    END IF;

    sql := format(
        c_template
        , range_type
        , subtype
        , creation_function
    );
    RAISE DEBUG 'executing sql: %', sql;
    EXECUTE sql;

    RETURN format( 'range_from_array(%s[])', subtype )::regprocedure;
END
$_range_from_array__create$;

SELECT _range_from_array__create(range_type)
    FROM range_type
    WHERE range_type_schema = 'pg_catalog'
;

