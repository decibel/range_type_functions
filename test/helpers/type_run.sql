SELECT plan(
  0
  + 1 * (SELECT count(*)::int FROM test)
--  + 2 * (SELECT count(*)::int FROM test) -- Creation functions
);

SELECT is(
    to_range(
        lower(expected)
        , upper(expected)
        , '[]'
        , expected
    )
    , expected
    , 'range__create from ' || description
  )
  FROM test
;

/*
SELECT is(
    range_from_array(input)
    , expected
    , description
  )
  FROM test
;
*/

\i test/pgxntool/finish.sql

-- vi: expandtab ts=2 sw=2
