# Mapper Graph Editor

The Mapper Graph editor is a visual, drag-and-drop tool for designing table relationships and generating ORM code. It bridges the gap between database design and code implementation.

## Overview

The Mapper Graph displays database tables as visual nodes on a graph canvas. You can:
- Drag tables onto the canvas
- Draw connections between related tables
- Generate entity classes and XML mapping files with one click

## Opening the Mapper Graph

In the GDSQL workbench, open a new Mapper Graph tab. The graph starts empty — add tables by dragging them from the database tree or using the add button.

## Working with Nodes

### Adding Tables

- Drag a table from the database tree onto the graph canvas
- Each table becomes a node showing its columns and types

### Node Display

Each node shows:
- Table name (header)
- Column names and their data types
- Primary key indicator

### Moving Nodes

Drag nodes freely to arrange the layout. The positions are saved in the `.gdmappergraph` file.

## Defining Relationships

### Creating Connections

1. Click on a column in one table node
2. Drag to a column in another table node
3. A connection line is drawn between them

### Relationship Types

- **One-to-one**: Connect primary key to primary key
- **One-to-many**: Connect primary key to foreign key

### Visual Indicators

Connection lines show the relationship direction and the columns involved.

## Code Generation

### One-Click Generation

Select one or more nodes and click **Generate**. GDSQL creates:

1. **Entity class (`.gd`)**: A GDScript class with `class_name`, typed properties matching table columns
2. **XML mapping file (`.xml`)**: A complete GBatis mapper with resultMap and CRUD statements
3. **Mapper Graph file (`.gdmappergraph`)**: Persists the layout and relationships

### Generated Entity Example

```gdscript
class_name HeroEntity extends RefCounted

var id: int
var name: String
var hp: int
var mp: int
```

### Generated XML Example

```xml
<mapper namespace="HeroMapper">
    <resultMap id="heroResult" type="HeroEntity">
        <id property="id" column="id"/>
        <result property="name" column="name"/>
        <result property="hp" column="hp"/>
        <result property="mp" column="mp"/>
    </resultMap>

    <select id="selectAll" resultMap="heroResult">
        SELECT * FROM c_hero
    </select>
</mapper>
```

## Type Inference

The generator automatically maps database column types to GDScript types:

| Database Type | GDScript Type |
|--------------|---------------|
| int | int |
| float | float |
| String | String |
| bool | bool |
| Vector2 | Vector2 |
| Color | Color |

## Incremental Sync

When the database schema changes (columns added, removed, or modified):

1. Open the Mapper Graph
2. Changed nodes are highlighted with visual indicators
3. Review the differences
4. Choose to sync selectively or fully

This prevents accidentally overwriting manual customizations in your entity code or XML files.

## File Format

The `.gdmappergraph` file stores:
- Which tables are on the canvas
- Node positions (x, y coordinates)
- Connection definitions (source table/column → target table/column)

This file can be committed to version control and shared with team members.
