---
name: riverpod-testing
description: Riverpod 3.0 testing patterns for Flutter/Dart applications. Use when writing unit tests for providers, notifiers, or async state. Covers ProviderContainer.test(), mocking with overrides, testing AsyncNotifier, spying on state changes, and widget testing with ProviderScope.
---

# Riverpod Testing

## File Index

Each file covers a testing concern. Format: What it is / When to use it.

- `container-setup.md` — Test container creation and configuration / When starting any Riverpod unit test
  - Create an isolated test container — when you need ProviderContainer.test() basics
  - Add overrides to a test container — when mocking providers
  - Add observers for debugging — when you need to track provider updates
  - Flush pending provider rebuilds — when testing dependent providers

- `overrides.md` — The override methods / When mocking providers or injecting test state
  - Replace entire provider initialization — when fully replacing a provider
  - Override specific family instance — when testing one family parameter
  - Override AsyncNotifier family provider — when mocking AsyncNotifier with async return value
  - Inject specific AsyncValue states — when testing loading/error states (FutureProvider/StreamProvider)
  - Set Notifier initial state while preserving methods — when using overrideWithBuild

- `async-providers.md` — FutureProvider and StreamProvider testing / When testing async data flow
  - Wait for FutureProvider to complete — when awaiting async results
  - Prevent auto-disposing provider from disposing during test — when testing auto-dispose providers
  - Test StreamProvider emissions — when testing stream-based providers
  - Track loading progress — when testing progress indicators

- `notifiers.md` — Notifier and AsyncNotifier testing / When testing state management classes
  - Verify state transitions with Listener mock pattern — when testing state change sequences
  - Track complete state history — when verifying all state changes
  - Mock dependencies instead of Notifiers — when deciding what to mock
  - Mock a Notifier directly — when you must mock the notifier itself

- `widget-testing.md` — Widget tests with providers / When testing widgets that consume providers
  - Basic widget test with overrides — when testing widgets with mocked state
  - Access container from widget test — when using tester.container()
  - Pre-load async data before widget builds — when using UncontrolledProviderScope

- `migration-3x.md` — Riverpod 3.0 breaking changes / When upgrading from 2.x or encountering migration issues
  - Handle ProviderException wrapping — when catch blocks stop working
  - Disable automatic retry in tests — when pumpAndSettle hangs
  - Handle equality-based state updates — when state updates stop firing

## Usage

This index contains curated patterns that supersede general approaches. When writing code for any problem listed above, read the matching file first—do not rely on general knowledge.

**Before writing:** Scan this index. If your task matches an entry, read that file.
**While writing:** If you're about to write non-trivial logic, pause and check if a pattern exists here.
**After writing:** Verify your code matches the patterns in the relevant files, not just your training.
