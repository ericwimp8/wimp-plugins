---
description: Fix failing tests for multiple TypeScript source files sequentially
argument-hint: [input]
---

# Batch Fix Tests Orchestrator

You are orchestrating a workflow to fix failing tests for multiple TypeScript source files.

## Input

The input `$1` may be:
- A path to a file containing file paths
- A space-separated list of file paths
- Text containing file paths somewhere within it

**Extract file paths** from the input by looking for:
- Paths ending in `.ts` or `.tsx`
- One path per line if reading from a file
- Skip empty lines and lines starting with `#` (comments)

If `$1` looks like a file path (exists on disk), read it and extract paths from its contents. Otherwise, parse `$1` directly for paths.

## Validation

Before processing, validate each extracted path:
- Must end in `.ts` or `.tsx`
- Must exist on disk
- Must not be a test file (no `.test.ts`, `.spec.ts`, `.test.tsx`, `.spec.tsx` suffix)

Report invalid paths but continue with valid ones. If no valid files remain, exit with an error.

## Execution Model

**Process files strictly sequentially.** Complete all phases for one file before starting the next. Never run multiple files in parallel—this ensures clean test states between files.

## Process

### For Each File

Process each valid source file by invoking the existing `/fix-tests-typescript` workflow:

1. **Announce** which file is being processed (e.g., "Processing file 2 of 5: src/services/userService.ts")

2. **Invoke fix-tests-typescript workflow** by launching the `test-writer-typescript:tw-discover-failing-tests` agent and following the same phases as `/fix-tests-typescript`:
   - Phase 1: Discover failing tests
   - Phase 2: Fix loop
   - Phase 3: Individual file handling (but defer final report)

3. **Track results** for this file:
   - Cases fixed
   - Cases stuck
   - Implementation bugs found
   - Clarifications needed

4. **Continue** to next file regardless of individual file outcome

### Derived Paths (per file)

For each source file, compute:
- **Plan file**: `test/plans/[filename]_fix_plan.md`
- **Test file**: Determined by project convention (see `/fix-tests-typescript` for detection logic)

### Test File Location Detection

TypeScript projects use one of two conventions:

| Pattern | Source | Test |
|---------|--------|------|
| **Alongside** | `src/services/userService.ts` | `src/services/userService.test.ts` |
| **Mirror** | `src/services/userService.ts` | `src/services/__tests__/userService.test.ts` |

**Detection:** Search for existing `*.test.ts` or `*.spec.ts` files:
- If tests exist in `__tests__/` subdirectories → use **mirror** pattern
- If tests exist alongside source files → use **alongside** pattern
- If no existing tests found → ask user once at the start of the batch

### Skills Detection (per file)

Check each source file's path and imports:
- `typescript-testing` - **Always pass**
- `jest-testing` - **Pass if** project uses Jest (check package.json)
- `jest-firebase-functions` - **Pass if** source is a Firebase Cloud Function (check for `functions/src/` path or `firebase-functions` imports)

Skills determination can be cached for the batch if all files are in the same project.

## Combined Report

After all files are processed, write a combined report.

**Report file path**: `test/reports/batch_fix_report_[timestamp].md`
- `[timestamp]` - current date/time as `YYYY-MM-DD_HHMMSS`

**Report structure**:

```markdown
# Batch Fix Report

Generated: [human-readable timestamp]

## Summary

- **Files processed**: [n]
- **Total cases fixed**: [n]
- **Total cases stuck**: [n]
- **Files with all tests passing**: [n]
- **Files with remaining issues**: [n]

## Results by File

| File | Cases Fixed | Cases Stuck | Status |
|------|-------------|-------------|--------|
| [filename] | [n] | [n] | ✓ Complete / ⚠ Issues |

## File Details

### [source_filename_1]

- **Source**: [path]
- **Test file**: [path]
- **Plan file**: [path]
- **Cases fixed**: [n]
- **Cases stuck**: [n]

[If any stuck cases or issues, describe them briefly]

### [source_filename_2]

[Repeat for each file]

## Technical Challenges

[Aggregate list of all implementation bugs, stuck cases, and clarification needs across all files]

## Manual Follow-up

[List any items requiring human attention, or state "None required."]
```

Write the report file, then confirm to the user:
- Report file location
- Overall summary (files processed, total cases fixed/stuck)
- Any files requiring attention

## Rules

1. **Sequential file processing**: Complete one file entirely before starting the next
2. **Continue on failures**: Don't stop the batch if one file has issues
3. **Track everything**: Aggregate results for the combined report
4. **Use existing workflow**: Follow the same phases as `/fix-tests-typescript` for each file
5. **Cache project-level settings**: Determine test pattern and skills once, reuse for all files in same project
