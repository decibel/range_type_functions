\set ECHO none

\i test/pgxntool/psql.sql

BEGIN;
\i sql/range_type_functions.sql

\echo # TRANSACTION INTENTIONALLY LEFT OPEN!

-- vi: expandtab sw=2 ts=2
