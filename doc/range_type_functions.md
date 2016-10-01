# Range Type Functions

## Views
### range_types
This view denormalizes most of the information about all of the range types in the system. It is based on the `pg_range` catalog table.

## Functions

Functions available in all releases of this extension.

### to_range() 

A polymorphic range constructor.

```sql
function to_range(range anyrange, low anyelement, high anyelement, bounds text DEFAULT '[)') returns anyrange
```

Create a range of **low**,**high** with the bounds specified by **bounds**.

#### Parameters:

* **range**: the type of the range to be created.
* **low**: The low-bound element value
* **high**: The high-bound element value
* **bounds**: The inclusivity/exclusivity bounds of the range, must be one of the following: '()', '(]', '[)', '[]'

#### Example

```sql
select to_range(null::int4range,4,5,'[]');
 to_range 
----------
 [4,6)
(1 row)

select to_range(null::daterange,'2015-01-01'::date,'2016-01-1','[)');
        to_range         
-------------------------
 [2015-01-01,2016-01-01)
(1 row)
```

```sql
function to_range( range anyrange, elem anyelement ) returns anyrange
```

Create a range of [**elem**].

#### Parameters:
* **range**: the type of the range to be created.
* **elem**: The sole element value that can be contained the result range

```sql
select to_range(null::daterange, '2015-01-01'::date);
        to_range         
-------------------------
 [2015-01-01,2015-01-02)
(1 row)
```

### range_from_array()
These functions will create a range type that spans all the values in the input array.

When the extention is installed, it will create types for all the range types that are in pg_catalog. You can create additional range_from_array() functions by calling `_range_from_array__create(range_type)`.

#### Parameters:
* **array** an array of a supported type.

```sql
select range_from_array( array[3,1,9,3] );
 range_from_array 
------------------
 [1,10)
(1 row)

select range_from_array( array[now(), now() - interval '1 day'] );
                         range_from_array                          
-------------------------------------------------------------------
 ["2016-09-30 16:16:18.516784-05","2016-10-01 16:16:18.516784-05"]
(1 row)
```

### element_range_comp()

Perform a strcmp-like comparison an element and a range.

```sql
function element_range_comp( range anyrange, element anyelement ) returns smallint
```

Return 0 if the element is within the range
Return -1 if the element is below the lower bound of the range.
Return 1 if the element is above the upper bound of the range.

#### Example
```sql
select element_range_comp('[10,100]'::int4range, 4);
 element_range_comp 
--------------------
                 -1
(1 row)

select element_range_comp('[10,100]'::int4range, 10);
 element_range_comp 
--------------------
                  0
(1 row)

select element_range_comp('[10,100]'::int4range, 110);
 element_range_comp 
--------------------
                  1
(1 row)
```

### is_singleton()

Determine if the range has only one possible element.

```sql
function is_singleton( range anyrange ) returns boolean
```

Returns true if the range is inclusive on both sides and the low element matches the high element.

#### Example
```sql
select is_singleton('[4,5)'::int4range);
 is_singleton 
--------------
 t
(1 row)

select is_singleton('[4,5]'::int4range);
 is_singleton 
--------------
 f
(1 row)
```

### get_lower_bound_condition

Given a range, express the simple where clause that would match the lower bound condition using range using only scalar comparisions.

```sql
create function get_lower_bound_condition(range anyrange, placeholder text default 'x') returns text
```

#### Examples
```sql
select get_lower_bound_condition('empty'::int4range);
 get_lower_bound_condition 
-------------------------------
 false
(1 row)

select get_lower_bound_condition('(,)'::int4range);
 get_lower_bound_condition 
-------------------------------
 true
(1 row)

select get_lower_bound_condition('(4,5]'::int4range);
 get_lower_bound_condition 
-------------------------------
 x >= '5'
(1 row)

select get_lower_bound_condition('(4,5]'::int4range,'y.z');
 get_lower_bound_condition 
-------------------------------
 y.z >= '5'
(1 row)

select get_lower_bound_condition('[4,5]'::int4range,'y.z');
 get_lower_bound_condition 
-------------------------------
 y.z >= '4'
(1 row)

select get_lower_bound_condition('[4,5]'::int4range,format('%I.%I','my schema','my ColuMnaME'));
   get_lower_bound_condition   
-----------------------------------
 "my schema"."my ColuMnaME" >= '4'
(1 row)
```

### get_upper_bound_condition

Given a range, express the simple where clause that would match the uppper bound condition using range using only scalar comparisions.

```sql
create function get_upper_bound_condition(range anyrange, placeholder text default 'x') returns text
```

#### Examples

```sql
select get_upper_bound_condition('empty'::int4range);
 get_upper_bound_condition 
-------------------------------
 false
(1 row)

select get_upper_bound_condition('(,)'::int4range);
 get_upper_bound_condition 
-------------------------------
 true
(1 row)

select get_upper_bound_condition('[4,5)'::int4range,'y.z');
 get_upper_bound_condition 
-------------------------------
 y.z < '5'
(1 row)

select get_upper_bound_condition('[4,5]'::int4range,'y.z');
 get_upper_bound_condition 
-------------------------------
 y.z < '6'
(1 row)
```

### get_bounds_condition_expr

Given a range, express the simple where clause that would match the uppper and lower bound conditions using range using only scalar comparisions.

```sql
create function get_upper_bounds_conditions(range anyrange, placeholder text default 'x') returns text
```

#### Examples

```sql
select get_bounds_condition_expr('empty'::int4range);
 get_bounds_condition_expr 
---------------------------
 false
(1 row)

select get_bounds_condition_expr('(,)'::int4range);
 get_bounds_condition_expr 
---------------------------
 true
(1 row)

select get_bounds_condition_expr('(4,5]'::int4range);
       get_bounds_condition_expr        
----------------------------------------
 x >= '5'::integer and x < '6'::integer
(1 row)

select get_bounds_condition_expr('(4,5]'::int4range,'y.z');
         get_bounds_condition_expr          
--------------------------------------------
 y.z >= '5'::integer and y.z < '6'::integer
(1 row)

select get_bounds_condition_expr('[4,5]'::int4range,'y.z');
         get_bounds_condition_expr          
--------------------------------------------
 y.z >= '4'::integer and y.z < '6'::integer
(1 row)

select get_bounds_condition_expr('[4,5)'::int4range,'y.z');
         get_bounds_condition_expr          
--------------------------------------------
 y.z >= '4'::integer and y.z < '5'::integer
(1 row)

select get_bounds_condition_expr('[4,5]'::int4range,'y.z');
         get_bounds_condition_expr          
--------------------------------------------
 y.z >= '4'::integer and y.z < '6'::integer
(1 row)
```

### get_bound_expr

Express a value casted as the subtype of the given range.

```sql
create function get_bound_expr(range anyrange, literal anyelement) returns text
```

#### Examples

```sql
select get_bound_expr(null::int4range,'4');
 get_bound_expr 
----------------
 '4'::integer
(1 row)

select get_bound_expr(null::daterange,'1991-09-23');
   get_bound_expr   
--------------------
 '1991-09-23'::date
(1 row)

select get_bound_expr(null::textrange,'ABEL');
         get_bound_expr         
--------------------------------
 'ABEL'::text COLLATE "default"
(1 row)

select get_bound_expr(null::textrange_c,'ABEL');
      get_bound_expr      
--------------------------
 'ABEL'::text COLLATE "C"
(1 row)
```

### get_collation_expr

Return the collation statement for a range type. Return null if the base type of the range does not use collation.

```sql
create function get_collation_expr(range anyrange) returns text
```

#### Examples

```sql
select get_collation_expr(null::int4range);
 get_collation_expr 
--------------------
 
(1 row)

select get_collation_expr(null::textrange);
 get_collation_expr 
--------------------
  COLLATE "default"
(1 row)

select get_collation_expr(null::textrange_c);
 get_collation_expr 
--------------------
  COLLATE "C"
(1 row)
```

### get_subtype_element_expr

Express a valid subtype by name with proper collation

```sql
create function get_subtype_element_expr(range anyrange, placeholder text default 'x') returns text
```

#### Examples

```sql
select get_subtype_element_expr('(4,5]'::int4range);
 get_subtype_element_expr 
--------------------------
 x
(1 row)

select get_subtype_element_expr('[ABEL,BAKER)'::textrange_c);
 get_subtype_element_expr 
--------------------------
 x COLLATE "C"
(1 row)
```



## Functions backported to 9.4

### range_merge()

Attempt to back-port the [function introduced in 9.5](http://www.postgresql.org/docs/9.5/static/functions-range.html#RANGE-FUNCTIONS-TABLE).

```sql
select range_merge('[4,5]'::int4range,'[9,10]'::int4range);
 range_merge 
-------------
 [4,11)
(1 row)
```


### Support

Submit issues to the [GitHub issue tracker](https://github.com/moat/range_type_functions/issues).

### Author

Corey Huinker, while working at [Moat](http://moat.com)

### Copyright and License

Copyright (c) 2015, Moat Inc.

Permission to use, copy, modify, and distribute this software and its documentation for any purpose, without fee, and without a written agreement is hereby granted, provided that the above copyright notice and this paragraph and the following two paragraphs appear in all copies.

IN NO EVENT SHALL MOAT INC. BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF Moat, Inc. HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

MOAT INC. SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE PROVIDED HEREUNDER IS ON AN "AS IS" BASIS, AND Moat, Inc. HAS NO OBLIGATIONS TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.

