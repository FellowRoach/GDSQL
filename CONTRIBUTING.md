# Contributing

## Getting Started

1. Clone the repository.
2. Open the project in Godot 4.7+.
3. Enable GDSQL in **Project Settings → Plugins**.
4. The GDSQL main screen button appears at the top of the editor.

## Development Setup

### Git Hooks

This repository includes a `pre-push` hook in `.githooks/` that automatically updates `file_manifest.txt` when pushing version tags.

Enable it once:

```bash
git config core.hooksPath .githooks
```

After this, every `git push` that includes a `v*` tag will trigger the hook to diff file changes and update the manifest.

> **Not required for casual contributions.** If you skip this, the CI workflow (`package.yml`) will handle the manifest when the tag is pushed to GitHub.

### Formatter

This repository uses the GDQuest GDScript formatter for code formatting. The formatter may be checked by a separate GitHub Actions workflow so it can be enabled, disabled, or adjusted independently from the test workflow. But it is better to use it, otherwise the `format.yml` may fail.

It is recommended to use the formatter inside Godot Editor, for better linting messages and syntax error detection.

If you have the formatter installed locally, you can run it before committing:

```bash
gdscript-formatter --safe addons/gdsql test
```

Preferebly it is better to keep code consistent and coherent by reordering it:
```bash
gdscript-formatter --reorder-code addons/gdsql test
```

## Code Style

* Type hints are encouraged (`var x: int`, `func f() -> void`).
* Prefer `%UniqueNodeName` over `get_node()`.
* Keep GDScript files formatted with the project formatter.
* Follow Linter orientations on new code, older code need dedicated care.

## Testing

Tests use the **GdUnit4** framework and live under `test/`.

```bash
# Run from Godot editor: open GdUnit panel → Run All
# Or via CLI:
godot --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd
```

## Pull Request Process

1. Ensure all tests pass before submitting.
2. Format changed GDScript files.
3. Update the version in `addons/gdsql/plugin.cfg` if the change warrants a release.
4. Tag the release commit with `vX.X.X` to trigger the packaging workflow.
