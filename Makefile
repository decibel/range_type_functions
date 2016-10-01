include pgxntool/base.mk

PG94 = $(call test, $(MAJORVER), -eq, 94)
LT94 = $(call test, $(MAJORVER), -lt, 94)

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

EXTRA_CLEAN += sql/range_type_functions.sql
