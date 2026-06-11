# Limitations

GDSQL is designed for game configuration data, not as a general-purpose database. Understanding its limitations helps you use it effectively.

## Performance

**GDSQL is pure GDScript.** It is not designed for real-time, high-throughput scenarios like:
- Processing thousands of queries per frame
- Large-scale data analytics
- Real-time multiplayer game state synchronization

For these scenarios, consider SQLite (via GDExtension) or a dedicated server database.

## Data Volume

GDSQL is optimized for **hundreds to tens of thousands of records** per table. Beyond that:
- Query execution time increases noticeably
- Memory usage grows (all data is loaded into memory)
- File I/O becomes a bottleneck

It is **not** suitable for:
- Data warehouses
- Datasets exceeding hundreds of thousands of rows
- Log files or telemetry data

## Concurrency

**No concurrent writes.** The ConfigFile-based engine does not support multi-threaded concurrent access. All database operations must run on the **main thread**.

If you need background data processing:
- Perform queries on the main thread
- Cache results for use in background threads (read-only)

## No Server Mode

GDSQL is a **local-only, file-based** data store:
- No network access
- No client-server architecture
- No multi-user concurrency
- No remote database connections

## No Referential Integrity

Foreign key relationships exist at the **application level only**. The storage engine does not enforce:
- Foreign key constraints
- Cascade deletes
- Referential integrity checks

You must manage relationships in your application code.

## Limited Indexing

Indexes are maintained in memory via `ImprovedConfigFile.set_indexed_props()`. There is:
- No persistent index structure
- No index optimization
- Re-indexing happens on every load

## No DDL Statements

Schema changes (creating tables, modifying columns) are currently only available through the **visual interface**. The following SQL statements are **not supported**:
- `CREATE TABLE`
- `ALTER TABLE`
- `DROP TABLE`
- `CREATE INDEX`

## File Format

All data is stored in `.cfg` files. While human-readable and VCS-friendly, this means:
- No binary compression (larger file sizes than binary databases)
- No built-in data validation beyond type checking
- Manual file edits can cause inconsistencies if not done carefully
