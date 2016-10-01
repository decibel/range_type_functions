\set ECHO none

\i test/pgxntool/setup.sql
SET search_path = :install_schema, tap;
SELECT plan(
    0
    + 4 -- to_range
    + 3 -- element_range_comp
    + 2 -- is_singleton
);

create type textrange as range (subtype = text);
create type textrange_c as range (subtype = text, collation = "C");

set datestyle = 'ISO';

select is(
    to_range(null::int4range, 4,5,'[]')
    , '[4,5]'::int4range
);

select is(
    to_range(null::daterange, '2015-01-01'::date,'2016-01-1')
    , '[2015-1-1,2016-1-1)'::daterange
);

select is(
    to_range(null::int4range, 4)
    , '[4,4]'::int4range
);

select is(
    to_range(null::daterange, '2015-01-01'::date)
    , '[2015-1-1,2015-1-1]'::daterange
);

select is(
    element_range_comp('[10,100]'::int4range, 4)
    , -1::smallint
    , $$element_range_comp('[10,100]'::int4range, 4)$$
);

select is(
    element_range_comp('[10,100]'::int4range, 10)
    , 0::smallint
    , $$element_range_comp('[10,100]'::int4range, 10)$$
);

select is(
    element_range_comp('[10,100]'::int4range, 110)
    , 1::smallint
    , $$element_range_comp('[10,100]'::int4range, 110)$$
);

select is(
    is_singleton('[4,5)'::int4range)
    , true
    , $$is_singleton('[4,5)'::int4range)$$
);

select is(
    is_singleton('[4,5]'::int4range)
    , false
    , $$is_singleton('[4,5]'::int4range)$$
);

\set ECHO ALL

select range_merge('[4,5]'::int4range,'[9,10]'::int4range);

select get_lower_bound_condition_expr('empty'::int4range);
select get_lower_bound_condition_expr('(,)'::int4range);
select get_lower_bound_condition_expr('(4,5]'::int4range);
select get_lower_bound_condition_expr('(4,5]'::int4range,'y.z');
select get_lower_bound_condition_expr('[4,5]'::int4range,'y.z');
select get_lower_bound_condition_expr('[4,5]'::int4range,format('%I.%I','my schema','my ColuMnaME'));
select get_upper_bound_condition_expr('empty'::int4range);
select get_upper_bound_condition_expr('(,)'::int4range);
select get_upper_bound_condition_expr('[4,5)'::int4range,'y.z');
select get_upper_bound_condition_expr('[4,5]'::int4range,'y.z');
select get_upper_bound_condition_expr('[ABEL,BAKER)'::textrange,'y.z');
select get_upper_bound_condition_expr('[ABEL,BAKER)'::textrange_c,'y.z');
select get_bounds_condition_expr('empty'::int4range);
select get_bounds_condition_expr('(,)'::int4range);
select get_bounds_condition_expr('(4,5]'::int4range);
select get_bounds_condition_expr('(4,5]'::int4range,'y.z');
select get_bounds_condition_expr('[4,5]'::int4range,'y.z');
select get_bounds_condition_expr('[4,5)'::int4range,'y.z');
select get_bounds_condition_expr('[4,5]'::int4range,'y.z');

select get_collation_expr(null::int4range);
select get_collation_expr(null::textrange);
select get_collation_expr(null::textrange_c);


select get_subtype_element_expr('(4,5]'::int4range);
select get_subtype_element_expr('[ABEL,BAKER)'::textrange_c);

select get_bound_expr(null::int4range,'4');
select get_bound_expr(null::daterange,'1991-09-23');
select get_bound_expr(null::textrange,'ABEL');
select get_bound_expr(null::textrange_c,'ABEL');

\i test/pgxntool/finish.sql
