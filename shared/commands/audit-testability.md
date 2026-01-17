---
description: Batch audit testability for multiple source files
argument-hint: [file-list-path] [output-directory]
---

# Batch Testability Audit

You are running a batch testability audit.

## Input

- **File list**: `$1` - Path to a file containing a list of source files to audit (one per line)
- **Output directory**: `$2` (optional) - Directory for audit reports. Defaults to `test/plan/audit/audit-[date]/` where `[date]` is today's date in `YYYY-MM-DD` format

## Process

### Step 1: Read File List

Read the file at `$1`. Each line should contain a path to a source file to audit.

- Skip empty lines
- Skip lines starting with `#` (comments)
- Trim whitespace from each line

If the file doesn't exist or is empty, report error and exit.

### Step 2: Determine Output Directory

If `$2` is provided:
- Use `$2` as the output directory

If `$2` is NOT provided:
- Generate default: `test/plan/audit/audit-[YYYY-MM-DD]/`
- Use today's date for the `[YYYY-MM-DD]` portion

Create the output directory if it doesn't exist.

### Step 3: Validate Files

Before launching agents, validate each file path:
- Check that the file exists
- Check that the file has a supported extension (`.dart`, `.ts`, `.tsx`, `.js`, `.jsx`)

Report any invalid files but continue with valid ones. If no valid files remain, exit.

### Step 4: Launch Parallel Audits

Process files using parallel agents with a **sliding window of 5 concurrent agents**.

**Determine plugin by extension:**

| Extension | Plugin Namespace | Default Skill |
|-----------|-----------------|---------------|
| `.dart` | `test-writer-dart` | (none) |
| `.ts`, `.tsx` | `test-writer-typescript` | `typescript-testing` |
| `.js`, `.jsx` | `test-writer-typescript` | (none) |

**Agent invocation prompt template** (without language skill):
```
Check testability of source file: {source_file_path}
Output: {output_directory}
```

**Agent invocation prompt template** (with language skill):
```
Check testability of source file: {source_file_path}
Skills: {skills_list}
Output: {output_directory}
```

**Sliding window execution:**

Maintain exactly 5 agents running at all times until fewer than 5 files remain.

1. **Initial launch**: Launch the first 5 files as parallel agents using multiple Task tool calls in a single message
2. **Monitor and refill**: As agents complete, immediately launch the next file from the queue
   - When an agent completes, launch the next queued file
   - Always keep 5 agents running until the queue is empty
3. **Drain remaining**: Once fewer than 5 files remain in the queue, let running agents complete without launching new ones
4. **Collect results**: Track results from each agent as they complete

**Example with 8 files (A, B, C, D, E, F, G, H):**
```
t0: Launch A, B, C, D, E (5 running, 3 queued)
t1: A completes → Launch F (5 running, 2 queued)
t2: C completes → Launch G (5 running, 1 queued)
t3: B completes → Launch H (5 running, 0 queued)
t4: D, E, F, G, H complete as they finish (draining)
```

This maximizes throughput by never leaving agent slots idle while files remain.

### Step 5: Generate Summary Report

After all agents complete, create a summary report at `{output_directory}/audit_summary.md`:

```markdown
# Testability Audit Summary

**Date**: [YYYY-MM-DD HH:MM:SS]
**Files audited**: [count]
**Output directory**: [path]

## Results by Score

| Score | Count | Files |
|-------|-------|-------|
| Good | [n] | [file1, file2, ...] |
| Fair | [n] | [file1, file2, ...] |
| Poor | [n] | [file1, file2, ...] |

## High-Impact Issues

[List all files with high-impact testability issues]

| File | High Issues | Summary |
|------|-------------|---------|
| [filename] | [count] | [brief description] |

## Individual Reports

[List paths to all generated report files]

- [filename]_testability.md
- ...

## Next Steps

[Suggestions based on findings]
```

### Step 6: Report to User

Summarize for the user:
- Total files audited
- Output directory location
- Distribution of testability scores
- Any files with high-impact issues requiring attention
- Path to the summary report

## Example

**Command:**
```
/audit-testability files_to_audit.txt
```

**Where `files_to_audit.txt` contains:**
```
lib/src/auth/user_service.dart
lib/src/data/repository.dart
lib/src/features/checkout/cart_service.dart
src/services/userService.ts
src/api/handlers.ts
```

**Result:**
- Creates `test/plan/audit/audit-2024-01-15/` directory
- Launches agents in parallel (all 5 at once in this case)
- Generates individual reports:
  - `user_service_testability.md`
  - `repository_testability.md`
  - `cart_service_testability.md`
  - `userService_testability.md`
  - `handlers_testability.md`
- Generates `audit_summary.md` with aggregate results

## Rules

1. **Maintain 5 concurrent agents** - Always keep 5 agents running until fewer than 5 files remain in the queue
2. **Immediate refill** - When an agent completes, immediately launch the next queued file
3. **Continue on individual failures** - If one file fails, continue with others
4. **Track all results** - Collect results from all agents for summary
5. **Create output directory** - Ensure the output directory exists before launching agents
