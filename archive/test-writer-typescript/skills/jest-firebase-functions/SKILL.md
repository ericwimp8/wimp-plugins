---
name: jest-firebase-functions
description: Jest testing patterns for Firebase Cloud Functions in TypeScript. Use when writing tests for HTTP triggers, callable functions, Firestore triggers, auth triggers, Pub/Sub, or scheduled functions. Covers ts-jest configuration, firebase-functions-test utilities, and firebase-admin mocking.
---

# Jest Firebase Functions Testing

## File Index

Each file covers a concern. Format: What it is / When to use it.

- `configuration.md` — Setup and initialization / When configuring Jest or firebase-functions-test
  - Install required dependencies — when setting up a new test suite
  - Configure Jest for TypeScript — when creating jest.config.ts
  - Initialize firebase-functions-test — when choosing online vs offline mode
  - Clean up test environment — when writing afterAll hooks
  - Mock config values — when function uses functions.config()
  - Prevent multiple initializeApp — when tests fail with initialization errors

- `http-functions.md` — HTTP trigger testing / When testing onRequest functions
  - Test with stubbed request/response — when testing HTTP function behavior
  - Test error responses — when verifying error status codes
  - Create reusable request factory — when setting up consistent request mocks
  - Create reusable response factory — when setting up chainable response mocks
  - Test async HTTP functions — when function returns a promise

- `callable-functions.md` — Callable function testing / When testing onCall functions
  - Wrap callable function — when preparing function for test invocation
  - Test unauthenticated access — when verifying auth requirements
  - Create authenticated context — when simulating logged-in users
  - Create admin context — when testing custom claims like admin privileges
  - Test HttpsError responses — when verifying error handling
  - Test with different auth providers — when testing OAuth scenarios

- `firestore-triggers.md` — Firestore trigger testing / When testing document triggers
  - Test onCreate in online mode — when using real Firebase connection
  - Test onCreate in offline mode — when mocking all Firebase services
  - Test onUpdate trigger — when testing before/after document changes
  - Test onDelete trigger — when testing cleanup logic
  - Provide context with path parameters — when matching document path wildcards
  - Create minimal snapshot — when building lightweight test data

- `auth-scheduled.md` — Auth and scheduled functions / When testing auth triggers or scheduled tasks
  - Test auth onCreate trigger — when testing user signup handlers
  - Test auth onDelete trigger — when testing account deletion cleanup
  - Create user record with provider data — when testing OAuth users
  - Test scheduled function — when testing pubsub.schedule functions
  - Test Pub/Sub triggered function — when testing message-based triggers
  - Decode Pub/Sub message data — when processing base64 encoded payloads

- `admin-mocking.md` — firebase-admin mocking / When testing in offline mode without Firebase connection
  - Create complete firebase-admin mock — when setting up __mocks__ folder
  - Use the mock in tests — when importing mocked admin
  - Override mock response — when customizing per-test behavior
  - Mock query results — when simulating collection queries
  - Mock batch operations — when testing batch writes
  - Mock transactions — when testing runTransaction
  - Mock external API calls — when function calls third-party APIs
  - Wait for async side effects — when testing triggers with delays

## Usage

This index contains curated patterns that supersede general approaches. When writing code for any problem listed above, read the matching file first—do not rely on general knowledge.

**Before writing:** Scan this index. If your task matches an entry, read that file.
**While writing:** If you're about to write non-trivial logic, pause and check if a pattern exists here.
**After writing:** Verify your code matches the patterns in the relevant files, not just your training.
