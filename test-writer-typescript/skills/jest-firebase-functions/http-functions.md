# HTTP Functions

Testing Firebase Cloud Functions HTTP triggers (onRequest).

## Test HTTP function with stubbed request/response

`helloWorld(req, res)`

HTTP functions receive Express-like request and response objects. Stub them as plain objects with jest.fn() mocks.

```typescript
import { helloWorld } from '../src/index';

describe('helloWorld', () => {
  test('returns greeting with valid name', (done) => {
    const req = {
      body: { name: 'Test User' },
    } as any;

    const res = {
      status: jest.fn().mockReturnThis(),
      send: jest.fn((payload) => {
        expect(payload).toBe('Hello Test User');
        done();
      }),
    } as any;

    helloWorld(req, res);
  });
});
```

## Test error responses

`res.status(400).send()`

Verify error status codes are set correctly.

```typescript
test('returns 400 without name', (done) => {
  const req = { body: {} } as any;

  const res = {
    status: jest.fn().mockReturnThis(),
    send: jest.fn(() => {
      expect(res.status).toHaveBeenCalledWith(400);
      done();
    }),
  } as any;

  helloWorld(req, res);
});
```

## Create reusable request factory

`createMockRequest(overrides)`

Factory function for consistent request mocking.

```typescript
function createMockRequest(overrides = {}) {
  return {
    body: {},
    query: {},
    params: {},
    headers: {},
    method: 'GET',
    ...overrides,
  } as any;
}
```

## Create reusable response factory

`createMockResponse()`

Factory function with chainable method mocks.

```typescript
function createMockResponse() {
  const res: any = {};
  res.status = jest.fn().mockReturnValue(res);
  res.json = jest.fn().mockReturnValue(res);
  res.send = jest.fn().mockReturnValue(res);
  res.set = jest.fn().mockReturnValue(res);
  res.end = jest.fn().mockReturnValue(res);
  return res;
}
```

## Use factories in tests

`createMockRequest({ body: {...} })`

Cleaner test setup with factory functions.

```typescript
test('handles POST request', (done) => {
  const req = createMockRequest({
    method: 'POST',
    body: { name: 'User' },
  });
  const res = createMockResponse();

  res.send = jest.fn((payload) => {
    expect(payload).toContain('User');
    done();
  });

  myFunction(req, res);
});
```

## Test async HTTP functions

`async (req, res) => {...}`

Use done callback or await the function if it returns a promise.

```typescript
test('handles async operation', async () => {
  const req = createMockRequest({ body: { id: '123' } });
  const res = createMockResponse();

  await asyncHttpFunction(req, res);

  expect(res.json).toHaveBeenCalledWith(
    expect.objectContaining({ success: true })
  );
});
```
