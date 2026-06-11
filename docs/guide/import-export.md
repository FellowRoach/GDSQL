# Import & Export

GDSQL supports importing and exporting data in multiple formats for interoperability with other tools.

## Export Formats

### CSV

Export table data as Comma-Separated Values:

```csv
id,name,hp,mp
1,Warrior,200,50
2,Mage,80,300
```

- Standard CSV format with header row
- Compatible with Excel, Google Sheets, and most spreadsheet tools
- Useful for bulk data editing outside Godot

### JSON

Export as JSON arrays:

```json
[
  {"id": 1, "name": "Warrior", "hp": 200, "mp": 50},
  {"id": 2, "name": "Mage", "hp": 80, "mp": 300}
]
```

- Machine-readable format
- Good for API integration and data exchange
- Preserves data types

### CFG

Export in Godot's native ConfigFile format:

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

- Native Godot format
- Human-readable
- Preserves all Godot data types (Vector2, Color, etc.)

## Import Formats

### From CSV

1. Open the target table in the workbench
2. Click **Import** → **CSV**
3. Select your CSV file
4. The importer maps columns by header name

### From JSON

1. Open the target table
2. Click **Import** → **JSON**
3. Select your JSON file
4. Data is appended or merged based on primary key

### From CFG

1. Open the target table
2. Click **Import** → **CFG**
3. Select your `.cfg` file

## Exporting Query Results

You can also export the results of SQL queries:

1. Write and execute a query in the SQL editor
2. In the results panel, click **Export**
3. Choose the format (CSV, JSON, or CFG)
4. Save to your desired location

## Tips

- Export to CSV when sharing data with designers who use spreadsheet tools
- Export to JSON when integrating with web services or external tools
- Export to CFG when backing up data or transferring between GDSQL projects
- Always verify imported data — column types should match the target table schema
