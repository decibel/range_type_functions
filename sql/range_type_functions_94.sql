
create function range_merge(a anyrange, b anyrange) returns anyrange
language plpgsql immutable strict as $$
declare
    r record;
    l_result text;
begin
    if a @> b then
        return a::text;
    end if;
    if a <@ b then
        return b::text;
    end if;
    if a <= b then
        if lower_inc(a) then
            l_result := '[';
        else
            l_result := '(';
        end if;
        l_result := l_result || lower(a)::text;
    else
        if lower_inc(b) then
            l_result := '[';
        else
            l_result := '(';
        end if;
        l_result := l_result || lower(b)::text;
    end if;
    l_result := l_result || ',';
    if a >= b then
        l_result := l_result || upper(a)::text;
        if upper_inc(a) then
            l_result := l_result || ']';
        else
            l_result := l_result || ')';
        end if;
    else
        l_result := l_result || upper(b)::text;
        if upper_inc(b) then
            l_result := l_result || ']';
        else
            l_result := l_result || ')';
        end if;
    end if;
    return l_result;
end;
$$;

grant execute on function range_merge(anyrange,anyrange) to public;

comment on function range_merge(anyrange,anyrange)
is E'Back-port of 9.5 range_merge()';

