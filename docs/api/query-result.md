# QueryResult API Reference

`QueryResult` wraps the result of a query execution, providing methods to access data, column headers, and status.

**Class**: `RefCounted`  
**Namespace**: `GDSQL.QueryResult`  
**Source**: `addons/gdsql/database/query_result.gd`

## Status

### `ok() -> bool`
Returns `true` if the query executed successfully.

### `get_err() -> String`
Returns the error message if the query failed.

## Accessing Data

### `get_data() -> Array`
Returns the result rows as an Array of Arrays. Each inner Array represents one row.

```gdscript
var result = dao.query()
if result.ok():
    var rows = result.get_data()
    for row in rows:
        print(row[0], row[1])  # Access by column index
```

### `get_head() -> Array`
Returns the column names as an Array of Strings. The order matches the SELECT clause.

```gdscript
var head = result.get_head()
# ["id", "name", "hp"]
```

## Data Properties

### `is_empty() -> bool`
Returns `true` if the result contains no rows.

### `size() -> int`
Returns the number of rows in the result.

## Usage Pattern

```gdscript
var result = GDSQL.BaseDao.new() \
    .use_db("game_config") \
    .select("id, name, hp") \
    .from("c_hero") \
    .where("hp > 100") \
    .query()

if result and result.ok():
    var head = result.get_head()   # ["id", "name", "hp"]
    var data = result.get_data()   # [[1, "Warrior", 200], ...]
    
    for row in data:
        var hero_name = row[head.find("name")]
        print(hero_name)
else:
    print("Query failed: ", result.get_err() if result else "null result")
```
