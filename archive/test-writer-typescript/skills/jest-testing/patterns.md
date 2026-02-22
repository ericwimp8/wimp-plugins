# Patterns

Test structure, mock management, and common testing patterns.

## Structure tests with describe/test

`describe()` / `test()`

```typescript
describe('FeatureName', () => {
  beforeAll(() => { /* One-time setup */ });
  afterAll(() => { /* One-time cleanup */ });
  beforeEach(() => { /* Per-test setup */ });
  afterEach(() => { /* Per-test cleanup */ });

  describe('methodName', () => {
    test('should do X when Y', async () => {
      // Arrange
      const input = createTestData();

      // Act
      const result = await methodUnderTest(input);

      // Assert
      expect(result).toEqual(expectedOutput);
    });

    test('should throw error when invalid input', async () => {
      await expect(methodUnderTest(null)).rejects.toThrow();
    });
  });
});
```

## Configure automatic mock reset in config

`clearMocks` / `resetMocks` / `restoreMocks`

```typescript
// jest.config.ts
{
  clearMocks: true,    // Clear mock.calls between tests
  resetMocks: true,    // Reset mock state between tests
  restoreMocks: true,  // Restore original implementations
}
```

## Manually reset mocks between tests

`jest.clearAllMocks()` / `jest.resetAllMocks()` / `jest.restoreAllMocks()`

```typescript
afterEach(() => {
  jest.clearAllMocks();    // Clear call history
  jest.resetAllMocks();    // Reset to initial state
  jest.restoreAllMocks();  // Restore spied methods
});
```

## Test with environment variables

`process.env`

```typescript
describe('with env vars', () => {
  const originalEnv = process.env;

  beforeEach(() => {
    jest.resetModules();
    process.env = { ...originalEnv };
  });

  afterAll(() => {
    process.env = originalEnv;
  });

  test('uses TEST_VAR', () => {
    process.env.TEST_VAR = 'test-value';
    const { getConfig } = require('../src/config');
    expect(getConfig().testVar).toBe('test-value');
  });
});
```

## Create factory function for test data

`createMockUser(overrides)`

```typescript
function createMockUser(overrides = {}) {
  return {
    uid: 'test-uid',
    email: 'test@example.com',
    displayName: 'Test User',
    ...overrides,
  };
}
```

## Create mock request helper

`createMockRequest(overrides)`

```typescript
function createMockRequest(overrides = {}) {
  return {
    body: {},
    query: {},
    params: {},
    headers: {},
    ...overrides,
  } as any;
}
```

## Create mock response helper

`createMockResponse()`

```typescript
function createMockResponse() {
  const res: any = {};
  res.status = jest.fn().mockReturnValue(res);
  res.json = jest.fn().mockReturnValue(res);
  res.send = jest.fn().mockReturnValue(res);
  res.set = jest.fn().mockReturnValue(res);
  return res;
}
```

## Test HTTP handler with mock request/response

`handler(req, res)`

```typescript
test('returns JSON response', () => {
  const req = createMockRequest({ body: { name: 'Test' } });
  const res = createMockResponse();

  handler(req, res);

  expect(res.status).toHaveBeenCalledWith(200);
  expect(res.json).toHaveBeenCalledWith({ success: true });
});
```

## Snapshot test output structure

`toMatchSnapshot()` / `toMatchInlineSnapshot()`

```typescript
test('response structure', async () => {
  const result = await generateReport();

  // Snapshot entire object
  expect(result).toMatchSnapshot();

  // Inline snapshot
  expect(result.summary).toMatchInlineSnapshot(`
    Object {
      "total": 100,
      "status": "complete",
    }
  `);
});
```
