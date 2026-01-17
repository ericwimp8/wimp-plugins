---
name: typescript-testing
description: TypeScript testing patterns for type-safe tests. Use when writing TypeScript unit tests, creating typed mocks, testing generics or type guards, handling async code, or avoiding common TypeScript testing pitfalls. Covers Jest, Vitest, and framework-agnostic patterns.
---

# TypeScript Testing

## File Index

Each file covers a concern. Format: What it is / When to use it.

- `type-assertions.md` — Compile-time and runtime type validation / When testing types match expectations
  - Validate type equality at compile time — when verifying type inference with `Expect<Equal<>>`
  - Assert types with expectTypeOf — when using fluent type assertions in Vitest/expect-type
  - Test that code should not compile — when verifying `@ts-expect-error` negative cases
  - Validate fixtures while preserving literal types — when using `satisfies` for test data

- `type-guards-conditionals.md` — Type guards, assertion functions, conditional types / When testing type narrowing behavior
  - Test type guard runtime behavior — when verifying guard returns correct boolean
  - Test type guard narrowing effect — when verifying type narrows in conditional branches
  - Test assertion functions — when testing `asserts value is T` functions
  - Test conditional type resolution — when verifying conditional types resolve correctly
  - Test distributive behavior over unions — when conditional types distribute over unions

- `mocking-patterns.md` — Type-safe mocks, stubs, dependency injection / When creating test doubles
  - Create typed mock objects with defaults — when using `Partial<T>` factory functions
  - Type mock functions preserving signatures — when using `jest.MockedFunction<typeof fn>`
  - Use constructor injection for testability — when making dependencies swappable
  - Abstract third-party dependencies — when mocking external libraries safely

- `async-testing.md` — Promises, timers, async iterators / When testing asynchronous code
  - Write async test functions correctly — when ensuring promises are awaited
  - Test promise rejections — when testing error paths with `.rejects`
  - Use fake timers for time-based code — when mocking `setTimeout`/`setInterval`
  - Handle recursive timers safely — when avoiding infinite timer loops
  - Test async iterators and generators — when testing `AsyncGenerator` output

- `test-data-patterns.md` — Builders, factories, Object Mother / When creating test fixtures
  - Use Builder pattern for flexible test data — when needing fluent method chaining
  - Use Object Mother for predefined scenarios — when reusing common test data
  - Create typed test context setup — when centralizing test dependencies

- `common-pitfalls.md` — Anti-patterns and mistakes / When reviewing tests for issues
  - Avoid using `any` to bypass type errors — when tempted to silence type errors
  - Avoid over-mocking creating tautological tests — when tests only verify mock setup
  - Avoid forgetting to await promises — when async tests pass incorrectly
  - Avoid path alias issues in tests — when imports fail in Jest but work in IDE

## Usage

This index contains curated patterns that supersede general approaches. When writing code for any problem listed above, read the matching file first—do not rely on general knowledge.

**Before writing:** Scan this index. If your task matches an entry, read that file.
**While writing:** If you're about to write non-trivial logic, pause and check if a pattern exists here.
**After writing:** Verify your code matches the patterns in the relevant files, not just your training.
