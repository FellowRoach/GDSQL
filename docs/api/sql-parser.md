# SQLParser API Reference

`GDSQL.SQLParser` parses SQL strings into executable `BaseDao` objects. It includes an LRU cache for performance.

**Class**: `RefCounted`  
**Namespace**: `GDSQL.SQLParser`  
**Source**: `addons/gdsql/database/sql_parser.gd`

## Core Methods

### `parse_to_dao(sql: String) -> BaseDao`
Parse a SQL string and return a configured `BaseDao` object ready for execution.

**Parameters:**
- `sql` — A complete SQL statement (SELECT, INSERT, UPDATE, DELETE, REPLACE)

**Returns:**
- `BaseDao` on success
- `null` on parse error

**Example:**
```gdscript
var dao = GDSQL.SQLParser.parse_to_dao("SELECT * FROM c_hero WHERE hp > 100")
if dao:
    var result = dao.query()
```

### `parse_select(sql: String) -> Array`
Parse a SELECT statement into its component parts. Returns an Array of `[keyword, content]` pairs.

### `parse_update(sql: String) -> Array`
Parse an UPDATE statement.

### `parse_delete(sql: String) -> Array`
Parse a DELETE statement.

### `parse_insert(sql: String) -> Array`
Parse an INSERT statement.

### `parse_replace(sql: String) -> Array`
Parse a REPLACE statement.

## Internal Methods

### `prepare_sql(sql: String) -> Array`
Pre-process SQL by extracting quoted strings and replacing them with placeholders. Returns `[processed_sql, replacements_map]`.

### `restore(s: String, map: Dictionary) -> String`
Restore placeholders back to original quoted strings.

### `replace_nested_sql_expression(expression: String, ...) -> Variant`
Handle nested subqueries within SQL expressions. Uses LRU cache for repeated expressions.

## LRU Cache

The parser maintains an LRU (Least Recently Used) cache of the last **1024** parsed SQL statements. Re-executing the same SQL string skips the parsing step, improving performance.

### Cache Behavior
- Automatic — no configuration needed
- Capacity: 1024 entries
- Eviction: Least recently used entries are removed when capacity is reached

## Supported SQL

| Statement | Support |
|-----------|---------|
| SELECT | Full — with WHERE, JOIN, GROUP BY, ORDER BY, LIMIT, UNION ALL, subqueries |
| INSERT | Full — with INSERT IGNORE, ON DUPLICATE KEY UPDATE |
| UPDATE | Full — with SET and WHERE |
| DELETE | Full — with WHERE |
| REPLACE | Full |
| CREATE/ALTER/DROP | Not supported — use the visual editor |

## Error Handling

Parse errors return `null` and trigger an assertion in debug mode. In the editor, errors are also displayed in a dialog.

```gdscript
var dao = GDSQL.SQLParser.parse_to_dao("INVALID SQL")
# Returns null, assertion fires with error message
```
