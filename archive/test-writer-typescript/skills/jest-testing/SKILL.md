---
name: jest-testing
description: TypeScript testing with Jest and ts-jest. Use when writing unit tests, mocking dependencies, testing async code, or controlling time. Covers ts-jest configuration, jest.fn/spyOn/mock, hoisting behavior, typed mocks with jest.mocked, fake timers, and testing patterns.
---

# Jest Testing for TypeScript

## File Index

Each file covers a concern. Format: What it is / When to use it.

- `configuration.md` — Project setup and config / When setting up Jest with TypeScript
  - Install test dependencies — when adding Jest to a TypeScript project
  - Configure Jest for TypeScript — when creating jest.config.ts
  - Configure TypeScript for tests — when tests aren't being recognized
  - Add test scripts — when setting up npm test commands

- `mocking-fundamentals.md` — Creating and asserting mock functions / When you need to mock function behavior
  - Create mock with implementation — when mocking function logic
  - Create mock that resolves/rejects — when mocking async functions
  - Assert mock call count — when verifying how many times a mock was called
  - Chain different implementations — when mock should return different values per call

- `module-mocking.md` — Mocking modules and spying on methods / When you need to mock imports or spy on objects
  - Auto-mock an entire module — when replacing all exports with mocks
  - Mock only specific exports — when keeping some real implementations
  - Mock default export — when mocking ES module default exports
  - Get type-safe mock reference — when you need TypeScript types on mocks
  - Spy on object method — when tracking calls without replacing implementation

- `async-testing.md` — Testing promises and callbacks / When testing asynchronous code
  - Test async function with await — when testing promise-returning functions
  - Assert promise resolves/rejects — when testing expected async outcomes
  - Test callback-based code — when testing callback patterns
  - Ensure assertions run — when async assertions might be skipped

- `timer-mocking.md` — Controlling time in tests / When testing code with setTimeout, setInterval, or Date
  - Enable fake timers — when tests depend on time
  - Advance time by duration — when triggering time-based logic
  - Set system time — when testing date-dependent code
  - Mix timers with promises — when async code uses timers

- `patterns.md` — Test structure and helpers / When organizing tests or creating utilities
  - Structure tests with describe — when organizing test suites
  - Configure automatic mock reset — when mocks leak between tests
  - Test with environment variables — when code reads process.env
  - Create factory functions — when tests need consistent test data
  - Create mock request/response helpers — when testing HTTP handlers

## Usage

This index contains curated patterns that supersede general approaches. When writing code for any problem listed above, read the matching file first—do not rely on general knowledge.

**Before writing:** Scan this index. If your task matches an entry, read that file.
**While writing:** If you're about to write non-trivial logic, pause and check if a pattern exists here.
**After writing:** Verify your code matches the patterns in the relevant files, not just your training.
