# Fluent DAO API

The Fluent DAO API lets you build database queries through GDScript method chaining — no SQL strings, no XML files needed. Every method returns the DAO object itself, enabling clean, readable chains.

## Basic Usage

```gdscript
var result = GDSQL.BaseDao.new() \
    .use_db("game_config") \
    .select("id, name, hp") \
    .from("c_hero") \
    .where("hp > 100") \
    .order_by("hp DESC") \
    .limit(10) \
    .query()
```

## Database Selection

### `use_db(database_name_or_path: String)`
Select a database by name or path. The system auto-detects whether the input is a name or a path (paths contain `/`).

```gdscript
.use_db("game_config")       # By name
.use_db("res://data/my_db")  # By path
```

### `use_db_name(database_name: String)`
Select a database by name only.

### `use_user_db()`
Use the `user://` database (user data directory).

### `use_conf_db()`
Use the database configured in GDSQL project settings.

## SELECT Queries

### `select(fields: String, reset: bool = true)`
Specify which columns to select. Pass `"*"` for all columns.

```gdscript
.select("id, name, hp")
.select("*")
.select("COUNT(*) as total")
```

### `from(table: String, alias: String = "")`
Specify the source table.

```gdscript
.from("c_hero")
.from("c_hero", "h")  # with alias
```

### `where(condition: String)`
Filter rows with a condition string. Supports all SQL operators.

```gdscript
.where("hp > 100 AND mp >= 50")
.where("name LIKE 'War%'")
.where("id IN (1, 2, 3)")
```

### `order_by(field: String, ascending: bool = true)`
Sort results by a field.

```gdscript
.order_by("hp")               # ascending
.order_by("hp", false)         # descending
.order_by_str("hp DESC, mp ASC")  # from string
```

### `limit(offset: int, count: int)`
Paginate results.

```gdscript
.limit(0, 10)    # first 10 rows
.limit(10, 10)   # rows 11-20
```

### `group_by(fields: String)`
Group rows by field(s).

```gdscript
.group_by("type")
```

### `left_join(db: String, table: String, alias: String, on: String, ...)`
Join another table.

```gdscript
GDSQL.BaseDao.new() \
    .use_db("game_config") \
    .select("h.name, s.skill_name") \
    .from("c_hero", "h") \
    .left_join("", "c_skill", "s", "h.id = s.hero_id") \
    .query()
```

### `union_all()`
Combine with another SELECT query.

```gdscript
var result = GDSQL.BaseDao.new() \
    .use_db("game_config") \
    .select("*").from("table_a") \
    .union_all() \
    .select("*").from("table_b") \
    .query()
```

## INSERT Operations

### `insert_into(table: String)`
Start an insert operation.

### `insert_ignore(table: String)`
Insert, but skip if the primary key already exists.

### `insert_or_update(table: String)`
Insert, or update if the primary key already exists (upsert).

### `values(data)`
Provide values as a Dictionary or Array.

```gdscript
# Dictionary (recommended)
.insert_into("c_hero") \
.values({"id": 101, "name": "NewHero", "hp": 200})

# Array (positional)
.insert_into("c_hero") \
.values([101, "NewHero", 200])
```

### `on_duplicate_update(fields: Array)`
For `insert_or_update`, specify which fields to update on conflict.

## UPDATE Operations

### `update(table: String)`
Start an update operation.

### `sets(data: Dictionary)`
Set the values to update.

```gdscript
GDSQL.BaseDao.new() \
    .use_db("game_config") \
    .update("c_hero") \
    .sets({"hp": 300, "mp": 150}) \
    .where("id = 101") \
    .query()
```

## DELETE Operations

### `delete_from(table: String)`
Start a delete operation.

```gdscript
GDSQL.BaseDao.new() \
    .use_db("game_config") \
    .delete_from("c_hero") \
    .where("id = 101") \
    .query()
```

## REPLACE Operations

### `replace_into(table: String)`
Insert a row, replacing any existing row with the same primary key.

## Executing Queries

### `query()`
Execute the built query and return a `QueryResult` object.

```gdscript
var result = dao.query()
if result.ok():
    var data = result.get_data()   # Array of rows
    var head = result.get_head()   # Column names
else:
    print(result.get_err())        # Error message
```

## Transaction Control

### `auto_commit(auto: bool)`
Control whether changes are automatically saved to disk.

```gdscript
.auto_commit(false)  # Changes only in memory
```

### `commit()`
Manually save changes to disk.

### `discard()`
Discard uncommitted changes.

## Password

### `set_password(password: String)`
Set the password for accessing encrypted tables.

```gdscript
.set_password("my_secret")
```

See the [API Reference](../api/base-dao) for the complete method list.
