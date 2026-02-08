---
name: file-tree
description: List all files in a directory, optionally filtered by file type. Use when you need to find all files of a specific type (e.g., all .ts files), explore a codebase structure, or get a flat list of paths for processing.
---

# File Tree

Generates a flat list of all file and directory paths in a directory.

## Script Location

[tree.sh](scripts/tree.sh)

## Usage

Run the script from the skill directory (paths are relative to skill root):

```bash
bash scripts/tree.sh <directory> <output-file> [--ignore "pattern1,pattern2"] [--type "ext"]
```

### Arguments

- `<directory>` - The directory to scan (required)
- `<output-file>` - Path to write the file tree to (required)

### Options

- `--ignore "pattern1,pattern2"` - Exclude directories/files by **name** (see below)
- `--type "ext"` - Only include files with this extension (e.g., `ts`, `dart`, `.md`)

## How `--ignore` Works

**IMPORTANT: Patterns match directory/file NAMES only, not paths.**

The script uses `find -name "pattern"` which matches the basename (final component) of each path.

| Pattern | Matches | Does NOT Match |
|---------|---------|----------------|
| `node_modules` | `project/node_modules`, `project/functions/node_modules`, `a/b/c/node_modules` | - |
| `Pods` | `ios/Pods`, `any/path/Pods` | - |
| `.gradle` | `android/.gradle`, `foo/.gradle` | - |
| `ios/Pods` | **NOTHING** - there's no directory literally named "ios/Pods" | `ios/Pods` (this is `Pods` inside `ios/`) |

**Common mistake:** Don't use paths like `ios/Pods` or `android/.gradle`. Use just the name: `Pods`, `.gradle`.

## Output

Writes one path per line to the output file, sorted alphabetically. No terminal output.

```
project/src/main.ts
project/src/utils/helper.ts
project/package.json
```

## Always Use Ignore Patterns

Generated code and dependency directories can contain thousands of files. Always ignore them.

### Examples

```bash
# Dart/Flutter project
bash scripts/tree.sh /path/to/project /path/to/output.txt \
  --ignore ".git,.dart_tool,build,.packages,Pods,.gradle,node_modules,.next"

# Node.js project
bash scripts/tree.sh /path/to/project /path/to/output.txt \
  --ignore ".git,node_modules,dist,.cache,.next,.turbo"

# Python project
bash scripts/tree.sh /path/to/project /path/to/output.txt \
  --ignore ".git,__pycache__,venv,.venv,.pytest_cache,.mypy_cache"

# Only Dart files
bash scripts/tree.sh /path/to/project /path/to/output.txt \
  --ignore ".git,.dart_tool" --type dart

# Only TypeScript files
bash scripts/tree.sh /path/to/project /path/to/output.txt \
  --ignore ".git,node_modules" --type ts
```

### Common Directories to Ignore

| Type | Directories |
|------|-------------|
| Git | `.git` |
| Dart/Flutter | `.dart_tool`, `build`, `.packages` |
| iOS | `Pods` |
| Android | `.gradle` |
| Node.js | `node_modules`, `.next`, `.turbo`, `dist`, `.cache` |
| Python | `__pycache__`, `venv`, `.venv`, `.pytest_cache`, `.mypy_cache` |
| IDEs | `.idea`, `.vscode` |
| Misc | `coverage`, `.npm-cache`, `artifacts` |
