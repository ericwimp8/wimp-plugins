# Async Testing

Testing asynchronous code with async/await, promises, and callbacks.

## Test async function with await

`async/await`

```typescript
test('async function', async () => {
  const data = await fetchData();
  expect(data).toBe('expected');
});
```

## Test async error with try/catch

`expect.assertions(n)`

```typescript
test('async error', async () => {
  expect.assertions(1);
  try {
    await failingAsyncCall();
  } catch (error) {
    expect(error).toMatch('error');
  }
});
```

## Assert promise resolves to value

`resolves.toBe()`

```typescript
test('resolves', async () => {
  await expect(asyncFn()).resolves.toBe('value');
});
```

## Assert promise rejects with error

`rejects.toThrow()`

```typescript
test('rejects', async () => {
  await expect(failingFn()).rejects.toThrow('error');
});
```

## Test callback-based async code

`done` callback

```typescript
test('callback test', (done) => {
  asyncWithCallback((error, data) => {
    expect(data).toBe('expected');
    done();
  });
});
```

## Ensure exact number of assertions run

`expect.assertions(n)`

```typescript
test('ensure assertions run', async () => {
  expect.assertions(2);

  const data = await fetchData();
  expect(data).toBeDefined();
  expect(data.value).toBe('test');
});
```

## Ensure at least one assertion runs

`expect.hasAssertions()`

```typescript
test('has assertions', async () => {
  expect.hasAssertions();

  const data = await fetchData();
  expect(data).toBeDefined();
});
```

## Test rejected promise from mock

`mockRejectedValue()`

```typescript
test('handles errors gracefully', async () => {
  mockDependency.mockRejectedValue(new Error('DB Error'));
  await expect(functionUnderTest()).rejects.toThrow('DB Error');
});
```
