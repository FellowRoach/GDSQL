# Smart Auto-Fill

GDSQL includes a smart auto-fill feature that analyzes existing data patterns and predicts subsequent values. This dramatically speeds up data entry for configuration tables.

## How It Works

The auto-fill engine uses **least-squares fitting** to detect numerical patterns in your data and extrapolate the next values. For string data, it detects numbering patterns and fills accordingly.

## Supported Data Types

| Type | Example Pattern | Auto-Fill Result |
|------|----------------|------------------|
| Numbers | `10, 20, 30` | `40, 50, 60` |
| Strings with numbers | `"item_001", "item_002"` | `"item_003", "item_004"` |
| Vector2 | `(1,0), (2,0)` | `(3,0), (4,0)` |
| Vector3 | `(0,0,1), (0,0,2)` | `(0,0,3), (0,0,4)` |
| Vector4 | Similar pattern detection | Extrapolated values |
| Vector2i/3i/4i | Integer variants | Integer extrapolation |
| Resource paths | `"res://img/01.png", "res://img/02.png"` | `"res://img/03.png"` |

## Usage

### In the Workbench

1. Select a column in the data table
2. Select 2 or more existing cells as the sample
3. Use the auto-fill command (via toolbar or context menu)
4. The engine fills subsequent empty rows based on the detected pattern

### Pattern Recognition

The auto-fill engine automatically detects:
- **Arithmetic sequences**: `1, 3, 5` → `7, 9, 11`
- **Numbering in strings**: `"level_1", "level_2"` → `"level_3", "level_4"`
- **Zero-padded numbers**: `"id_001", "id_002"` → `"id_003", "id_004"`
- **Vector patterns**: Component-wise linear extrapolation

## Least-Squares Fitting

For numerical data, the engine uses the least-squares method to find the best-fit line through the sample data points. This produces more accurate predictions than simple difference-based extrapolation, especially when the data has minor variations.

## Tips

- Select at least 2 cells for pattern detection (more cells = better accuracy)
- The pattern must be consistent across the selected cells
- Auto-fill works best with columns that have a clear sequential pattern
- For non-patterned data, use copy-paste or manual entry
