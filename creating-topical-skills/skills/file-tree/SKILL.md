---
name: file-tree
description: List all files in a directory, optionally filtered by file type. Use when you need to find all files of a specific type (e.g., all .ts files), explore a codebase structure, or get a flat list of paths for processing.
---

# File Tree

This skill provides a script to generate a flat list of all file and directory paths in a directory.

## Script Location

`skills/file-tree/scripts/tree.sh`

## Usage

```bash
bash skills/file-tree/scripts/tree.sh <directory> [--ignore "pattern1,pattern2"] [--type "ext"]
```

### Options

- `--ignore "pattern1,pattern2"` - Exclude directories/files matching these patterns
- `--type "ext"` - Only show files with this extension (e.g., `ts`, `dart`, `.md`)

## Output Format

The script outputs one path per line, ready for direct use with file operations:

```
project/src/main.ts
project/src/utils/helper.ts
project/package.json
```

## Important: Use Ignore Patterns

When inspecting projects, **always pass ignore patterns** for generated code and dependency caches. These directories add noise and can contain thousands of files.

### Example

```bash
# A typical Dart/Flutter project
bash skills/file-tree/scripts/tree.sh /path/to/project --ignore ".git,.dart_tool,build,.packages,ios/Pods,android/.gradle"

# A Node.js project
bash skills/file-tree/scripts/tree.sh /path/to/project --ignore ".git,node_modules,dist,.cache,.next"

# A Python project
bash skills/file-tree/scripts/tree.sh /path/to/project --ignore ".git,__pycache__,.venv,.pytest_cache,*.egg-info"

# Only TypeScript files
bash skills/file-tree/scripts/tree.sh /path/to/project --ignore ".git,node_modules" --type ts

# Only Dart files
bash skills/file-tree/scripts/tree.sh /path/to/project --ignore ".git,.dart_tool" --type dart
```

Inspect the project first to determine what should be ignored - look for dependency lock files, build configs, and framework-specific tooling directories.
