# Visual Workbench

The GDSQL workbench is available as a dedicated main screen in the Godot Editor. Click the **GDSQL** button at the top of the editor to access it.

## Overview

The workbench consists of several integrated panels:

- **Left panel**: Database tree browser
- **Center panel**: Table data / structure / SQL editor (tabbed)
- **Right panel**: Table inspector / detail panel

## Database Tree Browser

The tree view on the left displays all databases and their tables in a hierarchical structure.

- **Expand** a database to see its tables
- **Click** a table to open it in the data editor
- **Right-click** for context menu options (create, delete, rename, etc.)

## Data Table Viewer

The data viewer displays table contents in an Excel-like grid:

- **Scroll** to navigate large datasets
- **Click** a cell to edit it inline — changes are applied immediately
- **Drag** column borders to resize column widths
- **Sort** by clicking column headers

### Inline Editing

Click any cell to enter edit mode. The editor supports:

- Direct text input
- Type-appropriate editors for different data types (int, float, Vector2, etc.)
- Instant commit when you press Enter or click away

### Column Resizing

Drag the right border of any column header to resize. This is especially useful for viewing long string values.

## Table Structure Editor

Switch to the **Structure** tab to view and modify column definitions:

- Column name
- Data type
- Default value
- Comments / descriptions
- Primary key and auto-increment settings

## Schema Management

### Creating Databases

Use the **New Database** dialog to create a new database with a name.

### Creating Tables

Use the **New Table** dialog to define:
- Table name
- Column definitions (name, type, default, comment)
- Primary key column
- Auto-increment settings

### Deleting

Right-click a database or table in the tree to delete it.

## SQL Query Editor

The SQL editor provides a dedicated space to write and execute SQL queries:

- **Syntax-aware** input area
- **Execute** button to run queries
- **Results panel** showing query output in a grid
- **Query history** — automatically records executed queries

### Writing SQL

Type standard SQL syntax. GDSQL supports:

```sql
SELECT * FROM my_table WHERE hp > 100
INSERT INTO my_table VALUES (1, 'Hero', 200)
UPDATE my_table SET hp = 300 WHERE id = 1
DELETE FROM my_table WHERE id = 1
```

### Query Results

Results appear in a grid below the editor. You can:
- Browse all returned rows
- Export results to CSV, JSON, or CFG format

## Diff View

Compare table content between two versions. The diff view highlights:
- **Added** rows (green)
- **Deleted** rows (red)
- **Modified** rows (yellow)

This is useful for reviewing changes before committing to version control.

## Table Inspector

The right panel shows detailed information about the selected table:
- Column definitions
- Table metadata
- Data statistics
