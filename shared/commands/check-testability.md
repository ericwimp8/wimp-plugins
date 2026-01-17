---
description: Analyze a source file for testability issues
argument-hint: [source-file-path] [output-directory]
---

# Testability Checker

You are checking testability for: `$1`

Optional output directory: `$2` (defaults to `test/plan/audit/` if not provided)

## Determine Plugin and Skills

Based on the file extension, determine which plugin namespace to use:

| Extension | Plugin Namespace | Default Skill |
|-----------|-----------------|---------------|
| `.dart` | `test-writer-dart` | (none - universal patterns) |
| `.ts`, `.tsx` | `test-writer-typescript` | `typescript-testing` |
| `.js`, `.jsx` | `test-writer-typescript` | (none - universal patterns) |

If no matching plugin exists for the file type, report that the language is not yet supported.

## Invoke Agent

Invoke the `{plugin}:tw-check-testability` agent using the prompt template below.

**MANDATORY**: NEVER add any instructions or extra details of any kind to the prompt. Use the template below exactly, replacing placeholders in brackets.

**Prompt template** (without language skill, no output directory):
```
Check testability of source file: {source_file_path}
```

**Prompt template** (with language skill, no output directory):
```
Check testability of source file: {source_file_path}
Skills: {skills_list}
```

**Prompt template** (without language skill, with output directory):
```
Check testability of source file: {source_file_path}
Output: {output_directory}
```

**Prompt template** (with language skill and output directory):
```
Check testability of source file: {source_file_path}
Skills: {skills_list}
Output: {output_directory}
```

Where:
- `{plugin}` - plugin namespace determined by file extension (e.g., `test-writer-dart`)
- `{source_file_path}` - full path to source file to analyze (from `$1`)
- `{skills_list}` - comma-separated list of applicable testability skills
- `{output_directory}` - output directory from `$2` (only include if provided)

## Example

For `lib/src/auth/user_service.dart`:
- Plugin: `test-writer-dart`
- Agent: `test-writer-dart:tw-check-testability`

For `src/services/userService.ts`:
- Plugin: `test-writer-typescript`
- Agent: `test-writer-typescript:tw-check-testability`
- Skills parameter: `typescript-testing`

For `lib/src/auth/user_service.dart test/plan/audit/audit-2024-01-15/`:
- Plugin: `test-writer-dart`
- Agent: `test-writer-dart:tw-check-testability`
- Output parameter: `test/plan/audit/audit-2024-01-15/`
