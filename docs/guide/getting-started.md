# Quick Start

This guide walks you through creating your first database, defining a table, inserting data, and querying it — both visually and through code.

## Step 1: Open the Workbench

Click the **GDSQL** button at the top of the Godot editor to open the database workbench.

## Step 2: Create a Database

In the workbench, click the **New Database** button. Enter a name for your database, e.g. `game_config`.

This creates a new database directory under your project's data path.

## Step 3: Create a Table

With the database selected, click **New Table**. Define a table named `c_hero` with these columns:

| Column | Type | Description |
|--------|------|-------------|
| `id` | int | Primary key |
| `name` | String | Hero name |
| `hp` | int | Hit points |
| `mp` | int | Magic points |

## Step 4: Add Data

Switch to the **Data** tab. Click **Add Row** and fill in some sample data:

| id | name | hp | mp |
|----|------|----|----|
| 1 | Warrior | 200 | 50 |
| 2 | Mage | 80 | 300 |
| 3 | Archer | 150 | 100 |

## Step 5: Query with SQL

Open the **SQL Editor** tab. Write and execute:

```sql
SELECT name, hp FROM c_hero WHERE hp > 100 ORDER BY hp DESC
```

You'll see the results displayed in the results panel below.

## Step 6: Query with Code

In any GDScript file, use the Fluent DAO API:

```gdscript
extends Node

func _ready():
    # Query heroes with hp > 100
    var result = GDSQL.BaseDao.new() \
        .use_db("game_config") \
        .select("name, hp") \
        .from("c_hero") \
        .where("hp > 100") \
        .order_by("hp DESC") \
        .query()

    # result is a QueryResult object
    var data = result.get_data()
    for row in data:
        print(row)
```

## Step 7: Insert Data from Code

```gdscript
GDSQL.BaseDao.new() \
    .use_db("game_config") \
    .insert_into("c_hero") \
    .values({"id": 4, "name": "Paladin", "hp": 180, "mp": 120}) \
    .query()
```

## Next Steps

Now that you have the basics, explore:

- [Fluent DAO API](./dao-api) — Full API reference for chaining queries
- [GBatis ORM](./gbatis) — XML-based mapping for complex queries
- [Data Encryption](./encryption) — Protect sensitive game data
