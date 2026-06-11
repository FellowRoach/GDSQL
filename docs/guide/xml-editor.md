# XML Editor

GDSQL includes a built-in XML editor for editing GBatis mapping files directly within the Godot editor.

## Features

### Syntax Highlighting

The XML editor provides color-coded syntax highlighting for:
- XML tags and attributes
- String values
- Comments
- GBatis-specific elements (`<select>`, `<resultMap>`, `<if>`, etc.)

### Find and Replace

- **Find**: Search for text within the current XML file
- **Replace**: Find and replace text occurrences
- Keyboard shortcuts for quick access

### Tree View Navigation

A tree panel shows the XML document structure:
- `<mapper>` as the root node
- `<resultMap>`, `<select>`, `<insert>`, `<update>`, `<delete>` as child nodes
- Click a node to jump to that section in the editor

### Multi-Tab Editing

Open multiple XML files simultaneously in separate tabs. Switch between them freely.

## Opening the XML Editor

1. In the GDSQL workbench, right-click a mapper XML file in the file tree
2. Select **Open in XML Editor**
3. Or use the **XML Editor** button in the toolbar

## Editing Tips

- The editor validates XML structure as you type
- Use the tree view to quickly navigate large mapping files
- Save with `Ctrl+S` (or `Cmd+S` on macOS)
- The editor preserves formatting and indentation
