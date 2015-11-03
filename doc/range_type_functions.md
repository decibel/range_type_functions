# Range Type Functions

## Functions

Functions available in all releases of this extension.

### to_range() 

A polymorphic range constructor.

```sql
function to_range( low anyelement, high anyelement, bounds text, range anyrange) returns anyrange
```

Create a range of **low**,**high** with the bounds specified by **bounds**.

#### Parameters:

* **low**: The low-bound element value
* **high**: The high-bound element value
* **bounds**: The inclusivity/exclusivity bounds of the range, must be one of the following: '()', '(]', '[)', '[]'
* **range**: the type of the range to be created.

#### Example

```sql
select to_range(4,5,'[]',null::int4range);
 to_range 
----------
 [4,6)
(1 row)

select to_range('2015-01-01'::date,'2016-01-1','[)',null::daterange);
        to_range         
-------------------------
 [2015-01-01,2016-01-01)
(1 row)

```sql
function to_range( elem anyelement, range anyrange) returns anyrange
```

Create a range of [**elem**].

#### Parameters:
* **elem**: The sole element value that can be contained the result range
* **range**: the type of the range to be created.

```sql
select to_range('2015-01-01'::date,null::daterange);
        to_range         
-------------------------
 [2015-01-01,2015-01-02)
(1 row)
```

### element_range_comp()

Perform a strcmp-like comparison an element and a range.

```sql
function element_range_comp( element anyelement, range anyrange) returns smallint
```

Return 0 if the element is within the range
Return -1 if the element is below the lower bound of the range.
Return 1 if the element is above the upper bound of the range.

#### Example
```sql
select element_range_comp(4,'[10,100]'::int4range);
 element_range_comp 
--------------------
                 -1
(1 row)

select element_range_comp(10,'[10,100]'::int4range);
 element_range_comp 
--------------------
                  0
(1 row)

select element_range_comp(110,'[10,100]'::int4range);
 element_range_comp 
--------------------
                  1
(1 row)
```

### is_singleton()

Determine if the range has only one possible element.

```sql
function is_singleton( range anyrange) returns boolean
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

