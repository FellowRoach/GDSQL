# Introduction

**GDSQL** is a database SQL workbench plugin for the [Godot Engine](https://godotengine.org), built entirely on top of the `ConfigFile` system. It provides a complete data management solution for game developers who need a lightweight, version-control-friendly database that lives alongside their project files.

## What is GDSQL?

GDSQL stores all data in `.cfg` plain text files — Godot's native configuration format. There is no external database engine, no server process, and no additional runtime dependencies. Install the plugin and it works.

### Key Capabilities

| Feature | Description |
|---------|-------------|
| SQL Query Engine | Full SQL syntax: SELECT, INSERT, UPDATE, DELETE, REPLACE with JOIN, subqueries, aggregates |
| Visual Workbench | Excel-like data editing, tree browser, table structure editor, diff view |
| Fluent DAO API | Method chaining for all CRUD operations in pure GDScript |
| GBatis ORM | MyBatis-style XML mapping with dynamic SQL and result mapping |
| Mapper Graph Editor | Visual drag-and-drop editor for table relationships with code generation |
| Data Encryption | AES-256-CBC with DEK key hierarchy and password verification |
| XML Editor | Built-in editor with syntax highlighting and multi-tab support |
| i18n | 13 languages supported out of the box |

## Why GDSQL?

### vs. SQLite / GDSQLite

SQLite stores data in binary files — not diff-friendly in version control. GDSQL uses `.cfg` plain text, making every change visible in `git diff`. GDSQL also provides a visual editor and ORM framework that SQLite lacks.

### vs. Custom Resource Files

Godot's `.tres`/`.res` files are diffable but have no query capability. GDSQL gives you a full SQL engine, Excel-style editing, and ORM mapping on top of a text-based format.

## Who is GDSQL For?

- **Game developers** who manage large amounts of configuration data (items, skills, levels, NPCs, etc.)
- **Teams** that want a unified data workflow from design to runtime
- **Developers** who prefer SQL-style queries over custom data access code
- **Projects** that need version-control-friendly data files

## Limitations at a Glance

- Pure GDScript — not designed for high-throughput real-time scenarios
- Optimized for hundreds to tens of thousands of records
- No concurrent writes (main thread only)
- No server mode — local file-based storage only
- No DDL SQL statements (schema changes via visual editor)

See the [Limitations](./limitations) page for full details.
