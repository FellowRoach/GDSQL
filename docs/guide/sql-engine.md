# SQL Query Engine

GDSQL includes a complete SQL query engine built in pure GDScript. It parses standard SQL syntax and executes it against the ConfigFile-based data store.

## Supported SQL Statements

### SELECT

```sql
SELECT column1, column2 FROM table_name
SELECT * FROM table_name WHERE condition
SELECT column1, COUNT(*) FROM table_name GROUP BY column1 HAVING COUNT(*) > 1
SELECT a.*, b.name FROM table_a a LEFT JOIN table_b b ON a.id = b.a_id
SELECT * FROM table_name ORDER BY column1 DESC LIMIT 10 OFFSET 5
SELECT * FROM table_a UNION ALL SELECT * FROM table_b
```

**Supported clauses:**
- `SELECT` — column list, `*`, expressions, aggregate functions
- `FROM` — table name with optional alias
- `WHERE` — conditions with AND, OR, IN, NOT IN, BETWEEN, LIKE, IS NULL
- `ORDER BY` — ascending/descending, multiple columns
- `GROUP BY` — with `HAVING` clause
- `LIMIT` / `OFFSET` — pagination
- `LEFT JOIN` — with ON condition, chainable multi-table joins
- `UNION ALL` — combine result sets
- **Subqueries** — correlated and non-correlated

### INSERT

```sql
INSERT INTO table_name VALUES (value1, value2, value3)
INSERT INTO table_name (col1, col2) VALUES (value1, value2)
INSERT IGNORE INTO table_name VALUES (value1, value2)
INSERT INTO table_name VALUES (value1) ON DUPLICATE KEY UPDATE col1 = VALUES(col1)
```

### UPDATE

```sql
UPDATE table_name SET col1 = value1, col2 = value2
UPDATE table_name SET col1 = value1 WHERE condition
```

### DELETE

```sql
DELETE FROM table_name
DELETE FROM table_name WHERE condition
```

### REPLACE

```sql
REPLACE INTO table_name VALUES (value1, value2)
REPLACE INTO table_name (col1, col2) VALUES (value1, value2)
```

## Conditions

The WHERE clause supports:

| Operator | Example |
|----------|---------|
| Comparison | `hp > 100`, `name = 'Hero'` |
| AND / OR | `hp > 100 AND mp < 200` |
| IN / NOT IN | `id IN (1, 2, 3)` |
| BETWEEN | `hp BETWEEN 100 AND 200` |
| LIKE | `name LIKE 'War%'` |
| IS NULL / IS NOT NULL | `mp IS NULL` |

## Aggregate Functions

| Function | Description |
|----------|-------------|
| `COUNT(*)` | Count rows |
| `SUM(column)` | Sum of values |
| `AVG(column)` | Average value |
| `MIN(column)` | Minimum value |
| `MAX(column)` | Maximum value |
| `GROUP_CONCAT(column)` | Concatenate values |

## Expression Evaluation

GDSQL supports SQL-compatible expression evaluation:
- Arithmetic operators: `+`, `-`, `*`, `/`
- String concatenation
- Function calls
- Type conversion
- NULL semantics (three-valued logic)

## LRU Cache

The SQL parser includes an LRU cache that automatically stores the last 1024 parsed SQL statements. Repeated queries are parsed faster because the engine skips re-parsing.

## Using SQL from Code

You can execute SQL strings directly using the `SQLParser`:

```gdscript
var dao = GDSQL.SQLParser.parse_to_dao("SELECT * FROM c_hero WHERE hp > 100")
var result = dao.query()
```

Or use the [Fluent DAO API](./dao-api) for a more structured approach.
