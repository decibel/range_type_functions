\i test/pgxntool/setup.sql

CREATE TEMP TABLE test(
  description text NOT NULL
  , input :subtype[] NOT NULL
  , expected_closed :range_type NOT NULL
  , expected_open :range_type NOT NULL
);


