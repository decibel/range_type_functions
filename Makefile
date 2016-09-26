include pgxntool/base.mk

-- TODO: Remove this after merging pgxntool 0.2.1+
testdeps: $(TEST_SQL_FILES) $(TEST_SOURCE_FILES)

TEST_HELPER_FILES		= $(wildcard $(TESTDIR)/helpers/*.sql)
testdeps: $(TEST_HELPER_FILES)


PG94 = (call test, $(MAJORVER), -eq, 94)
LT94 = (call test, $(MAJORVER), -lt, 94)

ifeq ($(LT94),yes)
$(error Minimum version of PostgreSQL required is 9.4.0)
endif

# Support for multiple Postgres versions
#
# This is maybe a bit ugly with range_type_functions hard-coded, but for now I
# think simple is better.
PGVER_FILES = sql/range_type_functions_95.sql
ifeq ($(PG94),yes)
PGVER_FILES += sql/range_type_functions_94.sql
endif

sql/range_type_functions.sql: $(PGVER_FILES)
	cat $^ > $@
