# FAQ

## General

### Is GDSQL a real database?

No. GDSQL is a data management plugin that provides a SQL-like interface over Godot's `ConfigFile` system. It doesn't use SQLite or any external database engine. All data is stored in `.cfg` plain text files.

### Does GDSQL require a database server?

No. GDSQL is completely self-contained. No server process, no network connection, no external dependencies. Install the plugin and it works.

### Can I use GDSQL in exported games?

Yes. The same API works both in the editor and in exported games. GDSQL is a pure GDScript plugin with no editor-only dependencies.

### Which Godot versions are supported?

GDSQL requires **Godot 4.x**. It is not compatible with Godot 3.x.

## Data & Storage

### Where is my data stored?

Data is stored in `.cfg` files within your project directory. Each database is a directory, and each table is a `.cfg` file within that directory.

### Can I edit `.cfg` files manually?

Yes. The files are standard Godot ConfigFile format and can be edited in any text editor. However, be careful with the format — invalid syntax will cause errors when GDSQL loads the file.

### Is my data safe in `.cfg` files?

`.cfg` files are plain text — anyone with file access can read them. For sensitive data, use GDSQL's [built-in encryption](./encryption) feature.

### Can I use GDSQL alongside other data formats?

Yes. GDSQL doesn't interfere with other data systems. You can use `.tres`, `.json`, `.xml`, or any other format alongside GDSQL in the same project.

## SQL & Queries

### Does GDSQL support all SQL syntax?

GDSQL supports a substantial subset of SQL. See the [SQL Engine](./sql-engine) page for the full list of supported statements and clauses. Notably, DDL statements (CREATE TABLE, ALTER TABLE) are not supported — use the visual editor instead.

### Can I use subqueries?

Yes. Both correlated and non-correlated subqueries are supported.

### Is there a query size limit?

There's no hard limit, but performance degrades with very complex queries (multiple joins, nested subqueries). The LRU cache stores the last 1024 parsed queries for faster re-execution.

## GBatis

### Do I have to use GBatis?

No. GBatis is optional. You can use the [Fluent DAO API](./dao-api) for all database operations without any XML files. GBatis is recommended for complex queries and team workflows where separating SQL from code is beneficial.

### Can I mix Fluent DAO and GBatis?

Yes. You can use Fluent DAO for simple queries and GBatis for complex ones in the same project. They operate on the same data store.

## Performance

### How fast is GDSQL?

For typical game configuration data (hundreds to thousands of records), GDSQL is fast enough for most use cases. Simple queries execute in under a millisecond. Complex joins and large datasets will be slower than native database engines.

### Can I optimize query performance?

- Use `set_indexed_props()` on `ImprovedConfigFile` to create in-memory indexes
- Avoid `SELECT *` — select only the columns you need
- Use `LIMIT` to reduce result set size
- The LRU cache automatically speeds up repeated queries

## Troubleshooting

### The GDSQL button doesn't appear in the editor

Make sure the plugin is enabled: **Project → Project Settings → Plugins → GDSQL → Enabled**.

### Query returns empty results

- Verify the database name and table name are correct
- Check that the table has data (open it in the workbench)
- Ensure the WHERE condition matches existing data

### "Parse failed" error on SQL

- Check SQL syntax — GDSQL follows standard SQL conventions
- Ensure table and column names match exactly (case-sensitive)
- Avoid using SQL reserved words as table/column names without quoting
