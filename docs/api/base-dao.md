# BaseDao API Reference

`GDSQL.BaseDao` is the core class for building and executing database queries through a fluent, chainable API.

**Class**: `RefCounted`  
**Namespace**: `GDSQL.BaseDao`  
**Source**: `addons/gdsql/database/base_dao.gd`

## Creating an Instance

```gdscript
var dao = GDSQL.BaseDao.new()
```

## Database Selection

### `use_db(database_name_or_path: String) -> BaseDao`
Select database by name or path. Auto-detects based on presence of `/`.

### `use_db_name(database_name: String) -> BaseDao`
Select database by name.

### `use_user_db() -> BaseDao`
Use the `user://` directory as the database.

### `use_conf_db() -> BaseDao`
Use the database configured in project settings.

### `get_db() -> String`
Get the current database name.

## Authentication

### `set_password(password: String) -> BaseDao`
Set password for accessing encrypted tables.

### `get_password() -> String`
Get the current password.

## Transaction Control

### `auto_commit(auto: bool) -> BaseDao`
Enable or disable auto-commit. When disabled, changes stay in memory until `commit()`.

### `commit() -> void`
Manually save changes to disk.

### `discard() -> void`
Discard uncommitted in-memory changes.

## SELECT Operations

### `select(fields: String, reset: bool = true) -> BaseDao`
Set the columns to select. Use `"*"` for all columns.

**Parameters:**
- `fields` — Comma-separated column names, expressions, or `*`
- `reset` — If `false`, appends to existing select fields

**Example:**
```gdscript
.select("id, name, hp")
.select("COUNT(*) as total")
.select("*")
```

### `from(table: String, alias: String = "") -> BaseDao`
Set the source table.

**Parameters:**
- `table` — Table name
- `alias` — Optional table alias

### `where(condition: String) -> BaseDao`
Set the WHERE clause.

**Example:**
```gdscript
.where("hp > 100 AND mp >= 50")
.where("id IN (1, 2, 3)")
.where("name LIKE 'War%'")
```

### `order_by(field: String, ascending: bool = true) -> BaseDao`
Add an ORDER BY clause.

### `order_by_str(order_string: String) -> BaseDao`
Set ORDER BY from a string (e.g., `"hp DESC, mp ASC"`).

### `group_by(fields: String) -> BaseDao`
Set GROUP BY fields.

### `limit(offset: int, count: int) -> BaseDao`
Set LIMIT and OFFSET for pagination.

### `left_join(db: String, table: String, alias: String, on: String, extra: String) -> BaseDao`
Add a LEFT JOIN clause.

### `union_all() -> BaseDao`
Start a UNION ALL with the next SELECT query. Returns a new BaseDao for the second query.

## INSERT Operations

### `insert_into(table: String) -> BaseDao`
Start an INSERT operation.

### `insert_ignore(table: String) -> BaseDao`
Start an INSERT IGNORE (skip if primary key exists).

### `insert_or_update(table: String) -> BaseDao`
Start an INSERT with ON DUPLICATE KEY UPDATE (upsert).

### `values(data) -> BaseDao`
Provide values for INSERT. Accepts `Dictionary` or `Array`.

### `on_duplicate_update(fields: Array) -> BaseDao`
Specify which fields to update on duplicate key.

## UPDATE Operations

### `update(table: String) -> BaseDao`
Start an UPDATE operation.

### `sets(data: Dictionary) -> BaseDao`
Set the values to update.

## DELETE Operations

### `delete_from(table: String) -> BaseDao`
Start a DELETE operation.

## REPLACE Operations

### `replace_into(table: String) -> BaseDao`
Start a REPLACE operation (insert or replace by primary key).

## Execution

### `query() -> QueryResult`
Execute the built query. Returns a `QueryResult` object.

**Returns:**
- `QueryResult` with data on success
- `null` on parse error

**Example:**
```gdscript
var result = dao.query()
if result and result.ok():
    var data = result.get_data()
    for row in data:
        print(row)
```

## Internal Settings (Advanced)

### `set_evalueate_mode(enable: bool) -> BaseDao`
Enable expression evaluation for UPDATE/INSERT values.

### `set_collect_lack_table_mode(enable: bool) -> BaseDao`
Enable collecting missing table names (used internally for subqueries).

### `set_need_head(need: bool) -> BaseDao`
Control whether query results include a header row.

### `set_input_names(names: Array) -> BaseDao`
Set external table names for subquery resolution.

### `set_inputs(inputs: Array) -> BaseDao`
Set external table data for subquery resolution.
