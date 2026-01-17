---
description: Run existing tests and fix any failures for a Dart source file
argument-hint: [source-file-path]
---

# Fix Tests Orchestrator

You are orchestrating a workflow to fix failing tests for: `$1`

## Skills

These skills contain curated patterns that agents MUST invoke and read. Pass them to agents in Phase 2.

- `dart-testing` - **Always pass** for Dart testing patterns
- `riverpod-testing` - **Pass if** source file imports `riverpod`, `flutter_riverpod`, or `hooks_riverpod`

Before Phase 1, check the source file imports to determine which skills apply.

**Format:** `Skills: dart-testing` (add `riverpod-testing` if source uses Riverpod)

## Execution Model

**NEVER invoke multiple agents in parallel.** This workflow is strictly sequential—each agent must complete before the next starts.

## Derived Paths

From source file `$1`, compute:
- **Plan file**: `test/plans/[filename]_fix_plan.md` (filename without extension)
- **Test file**: Mirror path under `test/`, append `_test` before extension

Example:
- Source: `lib/src/features/auth/user_service.dart`
- Plan: `test/plans/user_service_fix_plan.md`
- Test: `test/src/features/auth/user_service_test.dart`

## Workflow

Execute these phases in order using the Task tool to invoke each agent.

### Phase 1: Discover Failing Tests

Invoke the `test-writer-dart:tw-discover-failing-tests` agent using the prompt template below.
- **Expected output**: Plan file at `test/plans/[source_file_name]_fix_plan.md` OR `Result: ALL_PASSING`

**If result is ALL_PASSING:** Report "All tests passing" and exit.

**MANDATORY**: NEVER add any instructions or extra details of any kind to the prompt. Use the template below exactly, replacing placeholders in brackets.

**Prompt template** (use this format exactly):
```
Discover failing tests in: {test_file_path}
Source: {source_file_path}
Plan: {plan_file_path}
```

Where:
- `{test_file_path}` - full path to test file
- `{source_file_path}` - full path to source file
- `{plan_file_path}` - full path to fix plan file

Wait for completion before proceeding.

### Phase 2: Fix Loop

Read the plan file and find all cases with status `pending` or `in_progress`.

Process each incomplete case **one at a time**, in plan order.

#### Run and Fix

Invoke the `test-writer-dart:tw-run-fix` agent using the prompt template below.

**Handle result:**
- SUCCESS → continue to next case
- IMPLEMENTATION_BUG → log and continue to next case
- NEEDS_CLARIFICATION → log and continue to next case
- STUCK → extract failure details from the report and retry with them as "Previous failure" (up to 2 retries), then continue if still stuck

**MANDATORY**: NEVER add any instructions or extra details of any kind to the prompt. Use the template below exactly, replacing placeholders in brackets.

**Prompt template** (use this format exactly):
```
Run and fix test file: {test_file_path}
Implementation: {source_file_path}
Plan: {plan_file_path}
Case: {case_id}
Max iterations: 9
Attempt: 1
Skills: dart-testing{riverpod_suffix}
```

**If retrying with a previous failure**, use this template instead:
```
Run and fix test file: {test_file_path}
Implementation: {source_file_path}
Plan: {plan_file_path}
Case: {case_id}
Max iterations: 9
Attempt: {attempt_number}
Skills: dart-testing{riverpod_suffix}

Previous failure:
{failure_details}
```

Where:
- `{test_file_path}` - full path to test file
- `{source_file_path}` - full path to source file being tested
- `{plan_file_path}` - full path to fix plan file
- `{case_id}` - case identifier from plan (e.g., `Case 1`)
- `{attempt_number}` - retry attempt number (2 for first retry, 3 for second retry)
- `{riverpod_suffix}` - add `, riverpod-testing` if source uses Riverpod, otherwise omit
- `{failure_details}` - exact failure information extracted from the report

Repeat for each incomplete case.

### Phase 3: Write Report

After all cases are processed, write a report file.

**Report file path**: `test/reports/[filename]_fix_report_[timestamp].md`
- `[filename]` - source file name without extension (same as plan file)
- `[timestamp]` - current date/time as `YYYY-MM-DD_HHMMSS`

Example: `test/reports/user_service_fix_report_2024-01-07_143022.md`

**Report structure** (use your judgment on exact wording and detail):

```markdown
# Fix Report: [source_filename]

Generated: [human-readable timestamp]

## Summary

- **Source**: [source file path]
- **Test file**: [test file path]
- **Cases fixed**: [n]
- **Cases stuck**: [n]

## Iteration Statistics

[Read the **Attempts** field from each case in the plan file]

| Case | Attempts | Total Iterations | Final Status |
|------|----------|------------------|--------------|
| [case_id] | 1: 3 (SUCCESS) | 3 | complete |
| [case_id] | 1: 9 (STUCK), 2: 9 (STUCK), 3: 5 (SUCCESS) | 23 | complete |

**Totals:**
- Total attempts: [sum of all attempt counts across all cases]
- Total fixer iterations: [sum of all iterations across all attempts]
- Cases resolved on first attempt: [n]
- Cases requiring retries: [n]

## Technical Challenges

[For each stuck case, implementation bug, or clarification need, describe:]
- The case identifier
- What went wrong or what blocked progress
- Any relevant error messages or context
- Suggested next steps if applicable

[If no challenges, state "All test cases fixed successfully."]

## Manual Follow-up

[List any items requiring human attention, or state "None required."]
```

Write the report file using the Write tool, then confirm to the user:
- Report file location
- Brief summary of results

## Rules

1. **Sequential execution**: Complete each phase before starting the next. NEVER invoke multiple agents in parallel.
2. **One case at a time**: Fix one test case completely before starting the next case.
3. **Log stuck cases**: Don't stop on failures, log and continue
4. **Verify with actual test runs**: Don't claim success without running tests
