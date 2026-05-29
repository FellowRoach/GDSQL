# Contributing

## Getting Started

1. Clone the repository.
2. Open the project in Godot 4.7+.
3. Enable GDSQL in **Project Settings → Plugins**.
4. The GDSQL main screen button appears at the top of the editor.

## Development Setup

### Git Hooks

This repository includes a `pre-push` hook in `.githooks/` that automatically updates the `file_manifest.txt` when pushing version tags.

Enable it once:

```bash
git config core.hooksPath .githooks
```

After this, every `git push` that includes a `v*` tag will trigger the hook to diff file changes and update the manifest.

> **Not required for casual contributions.** If you skip this, the CI workflow (`package.yml`) will handle the manifest when the tag is pushed to GitHub.

## Code Style

- Type hints are encouraged (`var x: int`, `func f() -> void`).
- Prefer `%UniqueNodeName` over `get_node()`.

## Testing

Tests use the **GdUnit4** framework and live under `test/`.

```bash
# Run from Godot editor: open GdUnit panel → Run All
# Or via CLI:
godot --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd
```

## Pull Request Process

1. Ensure all tests pass before submitting.
2. Update the version in `addons/gdsql/plugin.cfg` if the change warrants a release.
3. Tag the release commit with `vX.X.X` to trigger the packaging workflow.
