# Async Testing

Async tests require proper promise handling and timer control. Missing await creates false positives—tests pass before assertions run.

## Write async test functions correctly

`async (): Promise<void>`

Always await or return promises:

```typescript
test('fetches data correctly', async (): Promise<void> => {
  const data = await fetchData();
  expect(data).toBe('expected');
});
```

Use `expect.assertions` for extra safety:

```typescript
test('fetches data', async () => {
  expect.assertions(1);
  const data = await fetchData();
  expect(data).toBeDefined();
});
```

## Test promise rejections

`await expect(fn()).rejects.toThrow()`

Two patterns for testing error paths:

```typescript
// Pattern 1: .rejects matcher
test('throws on invalid input', async () => {
  await expect(failingOperation()).rejects.toThrow('Expected error');
  await expect(failingOperation()).rejects.toMatchObject({
    statusCode: 404,
    message: 'Not found'
  });
});

// Pattern 2: try/catch with expect.assertions
test('handles rejection', async () => {
  expect.assertions(2);
  try {
    await failingOperation();
  } catch (error) {
    expect(error).toBeInstanceOf(ApiError);
    expect((error as ApiError).statusCode).toBe(404);
  }
});
```

## Use fake timers for time-based code

`jest.useFakeTimers() / jest.advanceTimersByTime(ms)`

Mock timers instead of using real delays:

```typescript
beforeEach(() => jest.useFakeTimers());
afterEach(() => jest.useRealTimers());

test('delayed operation resolves after timeout', async () => {
  const promise = delayedOperation<string>('result', 1000);
  jest.advanceTimersByTime(1000);
  await expect(promise).resolves.toBe('result');
});

test('debounces input', () => {
  fireEvent.change(input, { target: { value: 'test' } });
  jest.advanceTimersByTime(500);
  expect(mockSearch).toHaveBeenCalled();
});
```

## Handle recursive timers safely

`jest.runOnlyPendingTimers()`

Avoid infinite loop with `runAllTimers`:

```typescript
// ❌ Recursive timers cause "Aborting after running 100000 timers"
jest.runAllTimers();

// ✅ Only run currently pending timers
jest.runOnlyPendingTimers();
```

## Clean up intervals after tests

`afterEach(() => jest.clearAllTimers())`

Prevent memory leaks from running intervals:

```typescript
afterEach(() => jest.clearAllTimers());

test('polls data', () => {
  const intervalId = startPolling();
  jest.advanceTimersByTime(5000);
  clearInterval(intervalId);
});
```

## Type timer return values correctly

`ReturnType<typeof setInterval>`

Cross-platform timer typing:

```typescript
class PollingService {
  private intervalId: ReturnType<typeof setInterval> | null = null;

  start(callback: () => void, interval: number): void {
    this.intervalId = setInterval(callback, interval);
  }

  stop(): void {
    if (this.intervalId) clearInterval(this.intervalId);
  }
}
```

## Test async iterators and generators

`for await (const item of generator)`

Collect and verify async generator output:

```typescript
async function* generateNumbers(): AsyncGenerator<number, void, unknown> {
  yield 1;
  yield 2;
  yield 3;
}

test('async generator yields expected values', async () => {
  const generator = generateNumbers();
  const values: number[] = [];

  for await (const num of generator) {
    values.push(num);
  }

  expect(values).toEqual([1, 2, 3]);
});
```

Reusable collector utility:

```typescript
async function collectAsyncIterable<T>(iterable: AsyncIterable<T>): Promise<T[]> {
  const results: T[] = [];
  for await (const item of iterable) {
    results.push(item);
  }
  return results;
}
```

## Avoid race conditions in tests

`await Promise.all([asyncA(), asyncB()])`

Properly await parallel operations:

```typescript
// ❌ Race condition - assertions may run before operations complete
test('updates both values', async () => {
  updateA();
  updateB();
  expect(getA()).toBe('updated');
});

// ✅ Wait for all operations
test('updates both values', async () => {
  await Promise.all([updateA(), updateB()]);
  expect(getA()).toBe('updated');
});
```

## Avoid real timers in tests

`jest.useFakeTimers()`

Real timers make tests slow and flaky:

```typescript
// ❌ Slow, flaky
await new Promise(r => setTimeout(r, 500));

// ✅ Fast, deterministic
jest.useFakeTimers();
jest.advanceTimersByTime(500);
```
