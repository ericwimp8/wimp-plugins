# Configuration

Setup and initialization for Jest testing of Firebase Cloud Functions.

## Install required dependencies

`npm install --save-dev jest ts-jest @types/jest firebase-functions-test`

Core testing stack: Jest with TypeScript support via ts-jest, plus the official Firebase functions testing library.

## Configure Jest for TypeScript

`jest.config.ts`

```typescript
import type { Config } from 'jest';

const config: Config = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/src'],
  testMatch: ['**/__tests__/**/*.ts', '**/?(*.)+(spec|test).ts'],
  moduleFileExtensions: ['ts', 'js', 'json', 'node'],
  clearMocks: true,
  restoreMocks: true,
};

export default config;
```

## Initialize firebase-functions-test in offline mode

`firebaseFunctionsTest()`

Offline mode requires no Firebase connection but requires mocking all Firebase services.

```typescript
import firebaseFunctionsTest from 'firebase-functions-test';

const testEnv = firebaseFunctionsTest();
```

## Initialize firebase-functions-test in online mode

`firebaseFunctionsTest(config, serviceAccountPath)`

Online mode connects to a real Firebase project. Useful for integration tests.

```typescript
import firebaseFunctionsTest from 'firebase-functions-test';

const testEnv = firebaseFunctionsTest({
  projectId: 'your-project-id',
  databaseURL: 'https://your-project.firebaseio.com',
  storageBucket: 'your-project.appspot.com',
}, './service-account.json');
```

## Clean up test environment

`testEnv.cleanup()`

Always call cleanup in afterAll to release resources.

```typescript
afterAll(() => {
  testEnv.cleanup();
});
```

## Mock config values

`testEnv.mockConfig(config)`

Provides mock values for `functions.config()` calls.

```typescript
testEnv.mockConfig({
  stripe: { key: 'test-key' },
  service: { api_url: 'https://test.api.com' },
});
```

## Prevent multiple initializeApp calls

`if (!admin.apps.length)`

Firebase throws if initializeApp is called more than once.

```typescript
if (!admin.apps.length) {
  admin.initializeApp();
}
```

## Clear mocks between tests

`jest.clearAllMocks()`

Prevents mock state from leaking between tests.

```typescript
beforeEach(() => {
  jest.clearAllMocks();
});
```

## Increase timeout for slow tests

`jest.setTimeout(ms)`

Default Jest timeout is 5 seconds. Increase for emulator or integration tests.

```typescript
// Global increase
jest.setTimeout(30000);

// Per-test increase
test('slow test', async () => {
  // ...
}, 30000);
```

## Enable Firebase debug logging

`process.env.DEBUG = 'firebase*'`

Useful for debugging test failures related to Firebase internals.

```typescript
process.env.DEBUG = 'firebase*';
```
