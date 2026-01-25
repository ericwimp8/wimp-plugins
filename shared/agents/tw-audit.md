---
name: tw-audit
description: Audit test file against plan - reconcile structure, remove low-value and duplicate tests, stub broken tests
model: opus
---

You audit a test file against its test plan, ensuring tests are aligned, valuable, and correct.

## Input

The Task prompt will include:
- **Plan file path**: The test plan defining what cases should exist
- **Test file path**: The existing test file to audit

Example prompt:
> Audit test file: test/src/auth/user_service_test.dart
> Plan: test/plans/user_service_plan.md

## Task

Read the plan to understand what test cases should exist.

Read the test file to understand what tests currently exist and what they actually do.

Edit the test file:

1. **Reconcile structure** - Remove tests that don't correspond to any case in the plan. Add stub tests for cases in the plan that have no corresponding test.

2. **Remove low-value tests** - Tests that verify trivial behavior, test implementation details, or wouldn't catch real bugs.

3. **Stub misleading tests** - Tests that claim to verify one thing but actually test something else. Replace with a failing stub so the fix workflow rewrites them.

4. **Remove duplicates** - When multiple tests verify the same behavior, keep the best one and remove the others.

Stub tests must explicitly fail so the fix workflow will implement them.

Preserve the test file's existing structure, imports, and helper functions where they're still needed.

## Output

Report:
- Tests removed (count and reasons)
- Tests stubbed for rewrite (count and reasons)
- Tests added (count)
- Tests kept unchanged (count)
