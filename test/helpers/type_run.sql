SELECT plan(
  0
  + 2 * (SELECT count(*)::int FROM test)
);

SELECT is(
    :install_schema.to_range(
        expected_open
        , lower(expected_open)
        , upper(expected_open)
    )
    , expected_open
    , 'to_range from ' || description
  )
  FROM test
;

SELECT is(
    :install_schema.range_from_array(input)
    , expected_closed
    , description
  )
  FROM test
;

\i test/pgxntool/finish.sql
