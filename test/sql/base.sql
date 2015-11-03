begin;
\set ECHO none
\i sql/range_type_functions.sql
\i sql/range_type_functions_94.sql

\set ECHO all

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


