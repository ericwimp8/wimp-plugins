# Test Writer TypeScript

Test generation for TypeScript using a multi-agent workflow.

## Motivation

I wanted to see if weaker models could handle harder tasks by breaking them into focused steps with looping and specialized agents.

Writing good tests is hard. You need to understand the code, identify meaningful behaviors, avoid common anti-patterns, write the test correctly, run it, diagnose failures, and iterate until it passes. Asking a single model to do all of this in one shot often produces shallow tests, fake-passing assertions, or tests that mock the thing they're supposed to test.

Test Writer breaks this into discrete phases: plan the cases → eliminate redundancy → write one test → run and fix → repeat. Each phase has a focused agent that does one thing well. The run-fix agent in particular uses a cheaper model (Haiku) and loops up to 9 times per test, consulting skills on every 3rd iteration to course-correct.

The result: even smaller models can produce high-quality tests because they're never asked to do too much at once.

I also wanted to build something modular where skills are a bolt-on to add language-specific functionality. The idea was: shared agents handle the methodology, skills handle the syntax patterns. I almost got there—the agents in `shared/` are truly language-agnostic. But each new language still ended up needing its own orchestrator commands to wire up the right skills and handle language-specific quirks (test runner commands, file conventions, etc.). Not quite plug-and-play, but close.

## Skill-Driven Testing

Agents are pushed to consult skills at every decision point:
- **tw-write-test** invokes language skills before writing any code
- **tw-run-fix** re-reads skills every 3rd iteration when stuck
- Skills contain curated patterns, common pitfalls, and framework-specific guidance

Available skills for TypeScript:
- **typescript-testing** — Type-safe testing patterns: typed mocks, testing generics and type guards, handling async
- **jest-testing** — Jest with ts-jest: configuration, jest.fn/spyOn/mock, hoisting, fake timers
- **jest-firebase-functions** — Firebase Cloud Functions testing: HTTP triggers, callable functions, Firestore triggers, Pub/Sub

---

## Commands

### /write-tests-typescript `<source-file>`

Orchestrates comprehensive test writing for a TypeScript source file.

**Phases:**

1. **Plan** — Invokes **tw-plan-cases** to analyze the source file. Identifies the system under test, classifies dependencies, partitions inputs, and produces a test plan with individual cases.

2. **Redundancy check** — Invokes **tw-check-redundancy** to eliminate duplicate or low-value cases from the plan.

3. **Write and run** — For each case in the plan (one at a time, never parallel):
   - Invokes **tw-write-test** to write the test code
   - Invokes **tw-run-fix** to run the test and iterate on failures

4. **Report** — Writes a summary report with statistics on iterations, stuck cases, and any implementation bugs found.

**Resumption:** If interrupted, the workflow resumes from the first incomplete case—planning is not repeated.

---

### /fix-tests-typescript `<source-file>`

Runs existing tests and fixes failures for a TypeScript source file.

**Process:** Discovers failing tests, then invokes **tw-run-fix** for each failure with iteration and retry loops.

---

### /fix-all-tests-typescript `<source-file>...`

Runs fix workflow for multiple source files sequentially.

---

## Agents

### tw-plan-cases

Analyzes a source file and produces a test plan. Uses a methodical process:
1. Identify the system under test (SUT)—never mock any part of it
2. Identify who calls this code in production
3. State the contract for each public method
4. Classify dependencies—only mock those crossing real boundaries (network, filesystem, time)
5. Partition inputs and identify boundaries
6. Eliminate low-value tests

**Output:** `test/plans/[filename]_plan.md` with cases, statuses, and pre-flight checks.

---

### tw-check-redundancy

Reviews a test plan and removes redundant cases. If multiple cases test the same behavior (same outcome for same partition), keeps only the most valuable one.

---

### tw-write-test

Writes a single test case from the plan. Follows Arrange → Act → Assert structure, consults skills for patterns, and updates the plan with the test name.

**Constraints enforced:**
- Never mock the SUT
- No tautological tests (expected value must be independent of implementation)
- No implementation verification unless crossing a boundary
- One behavior per test

---

### tw-run-fix

Runs tests and iterates on failures. Uses a cheaper model (Haiku) and loops up to 9 times per attempt.

**The loop:**
1. Run tests
2. If pass → exit SUCCESS
3. Diagnose failure (setup issue, assertion issue, logic issue, implementation bug, or unknown)
4. Every 3rd iteration: consult skills, compare approach to patterns, rewrite if diverged
5. Apply minimal fix
6. Increment and repeat

**Exit conditions:**
- **SUCCESS** — Tests pass
- **IMPLEMENTATION_BUG** — Code violates requirements (with evidence)
- **NEEDS_CLARIFICATION** — Cannot determine correct behavior
- **STUCK** — Max iterations reached, hands off to orchestrator for retry

---

### tw-check-testability

Analyzes source code for testability issues before attempting to write tests. Flags tight coupling, hidden dependencies, and missing seams.

---

### tw-discover-failing-tests

Runs the test suite and identifies which tests are currently failing, for the fix workflow.

---

## Rules

The agents enforce these testing principles:

1. **Never mock the SUT** — The thing you're testing must be real
2. **Only mock boundary-crossing dependencies** — Database, network, filesystem, time. Not "separate class" or "injected interface"
3. **No tautological tests** — Expected values must be independent of implementation
4. **No fake-passing tests** — Every test must be capable of failing
5. **Implementation is source of truth** — Unless explicit requirements contradict
6. **Sequential processing** — One file, one case, one iteration at a time
