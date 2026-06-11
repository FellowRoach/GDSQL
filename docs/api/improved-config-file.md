# ImprovedConfigFile API Reference

`ImprovedConfigFile` extends Godot's `ConfigFile` with additional features like indexing and enhanced data access.

**Class**: `ConfigFile`  
**Namespace**: `GDSQL.ImprovedConfigFile`  
**Source**: `addons/gdsql/database/improved_config_file.gd`

## Overview

`ImprovedConfigFile` is the underlying storage engine for GDSQL tables. It wraps Godot's standard `ConfigFile` with:

- In-memory indexing for faster lookups
- Enhanced data manipulation methods
- Table structure management

## Key Methods

### `set_indexed_props(properties: Array)`
Create in-memory indexes on specified properties (columns) for faster WHERE clause evaluation.

```gdscript
# After loading a table, create an index on the "id" column
var config = GDSQL.ImprovedConfigFile.new()
config.load("res://data/my_db/c_hero.cfg")
config.set_indexed_props(["id"])

# Queries filtering by "id" will now be faster
```

### Standard ConfigFile Methods

Since `ImprovedConfigFile` extends `ConfigFile`, all standard methods are available:

```gdscript
config.set_value("section", "key", value)
config.get_value("section", "key", default)
config.has_section("section")
config.get_sections()
config.erase_section("section")
config.save("path.cfg")
config.load("path.cfg")
config.save_encrypted("path.cfg", key)
config.load_encrypted("path.cfg", key)
```

## Data Structure

Each table is stored as a ConfigFile where:
- **Sections** are row indices (`"0"`, `"1"`, `"2"`, ...)
- **Keys** are column names
- **Values** are the cell data

```ini
[0]
id=1
name="Warrior"
hp=200

[1]
id=2
name="Mage"
hp=80
```

## Performance Notes

- All data is loaded into memory on first access
- Indexes are maintained in memory and rebuilt on each load
- For large tables, indexing the most-queried columns significantly improves WHERE clause performance
- Save operations write the entire file to disk
