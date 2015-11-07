
create function to_range(low anyelement, high anyelement, bounds text, range anyrange) returns anyrange
language plpgsql immutable as $$
declare
    l_range text;
begin
    execute format('select %s($1,$2,$3)',pg_typeof(range)) using low, high, bounds into l_range;
    return l_range;
end
$$;

grant execute on function to_range(anyelement,anyelement,text,anyrange) to public;

comment on function to_range(low anyelement, high anyelement, bounds text, range anyrange)
is E'Given a lower bound, upper bound, bounds description, return a range of the given range type.';

create function to_range(elem anyelement, range anyrange) returns anyrange
language sql immutable as $$
select to_range(elem,elem,'[]',range);
$$;

grant execute on function to_range(anyelement,anyrange) to public;

comment on function to_range(elem anyelement, range anyrange)
is E'Convert an element e into the range [e].';

create function element_range_comp(element anyelement, range anyrange) returns smallint
language sql strict immutable as $$
select  case
            when to_range(element,range) << range then -1::smallint
            when to_range(element,range) <@ range then 0::smallint
            when to_range(element,range) >> range then 1::smallint
        end;
$$;

comment on function element_range_comp(anyelement,anyrange)
is E'Perform a strcmp-like comparison of an element and a range type.\n'
    'Return 0 if the element is within the range.\n'
    'Return -1 if the element is below the lower bound of the range.\n'
    'Return 1 if the element is above the upper bound of the range.\n';

create function is_singleton(range anyrange) returns boolean
language sql immutable as $$
select range is not distinct from to_range(lower(range),range);
--select lower_inc(range) and upper_inc(range) and lower(range) = upper(range);
$$;

grant execute on function is_singleton(anyrange) to public;

comment on function is_singleton(range anyrange)
is E'Returns true if the range has only one possible element.';

create function express_lower_bound_condition(range anyrange, placeholder text default 'x') returns text
language sql immutable as $$
select  case
            when lower_inf(range) then 'true'
            when isempty(range) then 'false'
            when lower_inc(range) then format('%s >= %L',placeholder,lower(range))
            else format('%s > %L',placeholder,lower(range))
        end;
$$;

comment on function express_lower_bound_condition(anyrange,text)
is E'Given a range and a placeholder value, construct the where-clause fragment for the lower bound of the range\n';

grant execute on function express_lower_bound_condition(anyrange,text) to public;

create function express_upper_bound_condition(range anyrange, placeholder text default 'x') returns text
language sql immutable as $$
select  case
            when upper_inf(range) then 'true'
            when isempty(range) then 'false'
            when upper_inc(range) then format('%s <= %L',placeholder,upper(range))
            else format('%s < %L',placeholder,upper(range))
        end;
$$;

comment on function express_upper_bound_condition(anyrange,text)
is E'Given a range and a placeholder value, construct the where-clause fragment for the upper bound of the range';

grant execute on function express_upper_bound_condition(anyrange,text) to public;

create function express_bounds_conditions(range anyrange, placeholder text default 'x') returns text
language sql immutable as $$
select  case
            when lower(range) = upper(range) then format('%s = %L',placeholder,lower(range))
            when isempty(range) then 'false'
            when lower_inf(range) and upper_inf(range) then 'true'
            when lower_inf(range) then express_upper_bound_condition(range,placeholder)
            when upper_inf(range) then express_lower_bound_condition(range,placeholder)
            else format('%s and %s',
                        express_lower_bound_condition(range,placeholder),
                        express_upper_bound_condition(range,placeholder))
        end;
$$;

comment on function express_bounds_conditions(anyrange,text)
is E'Given a range and a placeholder value, construct the where-clause fragment for the range';

grant execute on function express_bounds_conditions(anyrange,text) to public;



