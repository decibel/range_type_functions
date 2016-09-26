begin;
\set ECHO none

CREATE EXTENSION IF NOT EXISTS range_type_functions;
--\i sql/range_type_functions.sql
--\i sql/range_type_functions_94.sql

\set ECHO all

create type textrange as range (subtype = text);
create type textrange_c as range (subtype = text, collation = "C");

set datestyle = 'ISO';

select to_range(4,5,'[]',null::int4range);

select to_range('2015-01-01'::date,'2016-01-1','[)',null::daterange);

select to_range(4,null::int4range);

select to_range('2015-01-01'::date,null::daterange);

select element_range_comp(4,'[10,100]'::int4range);

select element_range_comp(10,'[10,100]'::int4range);

select element_range_comp(110,'[10,100]'::int4range);

select is_singleton('[4,5)'::int4range);

select is_singleton('[4,5]'::int4range);

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

rollback;
