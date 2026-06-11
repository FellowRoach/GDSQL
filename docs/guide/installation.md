# Installation

## Requirements

- **Godot Engine** 4.x
- No additional dependencies or plugins required

## Step 1: Download the Plugin

### Option A: Git Clone (Recommended)

Clone the repository directly into your project's `addons/` directory:

```bash
cd your_godot_project/addons/
git clone https://github.com/jinyangcruise/GDSQL.git gdsql
```

### Option B: Download ZIP

1. Download the latest release ZIP from [GitHub Releases](https://github.com/jinyangcruise/GDSQL/releases)
2. Extract the `addons/gdsql` folder into your project's `addons/` directory

Your project structure should look like:

```
your_godot_project/
├── addons/
│   └── gdsql/
│       ├── plugin.cfg
│       ├── basic/
│       ├── database/
│       ├── gbatis/
│       └── ...
├── project.godot
└── ...
```

## Step 2: Enable the Plugin

1. Open your project in the Godot Editor
2. Go to **Project → Project Settings → Plugins**
3. Find **GDSQL** in the list
4. Change its status to **Enabled**

## Step 3: Access the Workbench

After enabling, a **GDSQL** button appears at the top of the Godot editor. Click it to switch to the GDSQL main screen — the visual database workbench.

## Verifying Installation

To verify GDSQL is working, try this in any GDScript file:

```gdscript
func _ready():
    var dao = GDSQL.BaseDao.new()
    print("GDSQL loaded successfully!")
```

If the project runs without errors, GDSQL is ready to use.

## Next Steps

- [Quick Start](./getting-started) — Create your first database and run a query
- [Visual Workbench](./workbench) — Explore the editor interface
- [Fluent DAO API](./dao-api) — Start writing database queries in code
