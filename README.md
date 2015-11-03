# Range Type Functions

[![PGXN version](https://badge.fury.io/pg/range_type_functions.svg)](https://badge.fury.io/pg/range_type_functions)

This extension serves two purposes:
1. Extend the capabilities of range functions, with an eye toward moving the most useful of those functions into the core.
2. Facilitate back-porting of functions from newer versions of PostgreSQL.

## USAGE
For function documentation and examples, see the [range_type_functions.md file](doc/range_type_functions.md).

## INSTALLATION

Requirements: PostgreSQL 9.4 or greater.

In the directory where you downloaded range_type_functions, run

```bash
make install
```

Log into PostgreSQL.

```sql
CREATE EXTENSION range_type_functions;
```

or
```sql
CREATE EXTENSION range_type_functions SCHEMA my_schema;
```

All functions created have execute granted to public.

## UPGRADE

Run "make install" same as above to put the script files and libraries in place. Then run the following in PostgreSQL itself:

```sql
ALTER EXTENSION range_type_functions UPDATE TO '<latest version>';
```

