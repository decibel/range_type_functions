
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

