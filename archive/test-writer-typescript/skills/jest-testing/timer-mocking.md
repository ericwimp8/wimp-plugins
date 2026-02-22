# Timer Mocking

Controlling time in tests with fake timers.

## Enable fake timers

`jest.useFakeTimers()`

```typescript
beforeEach(() => {
  jest.useFakeTimers();
});

afterEach(() => {
  jest.useRealTimers();
});
```

## Run all pending timers to completion

`jest.runAllTimers()`

Executes all queued timers, including new ones created during execution.

## Run only currently pending timers

`jest.runOnlyPendingTimers()`

Executes pending timers but not new ones created during execution.

## Advance time by specific duration

`jest.advanceTimersByTime(ms)`

```typescript
jest.advanceTimersByTime(1000); // Advance 1 second
```

## Advance to next timer

`jest.advanceTimersToNextTimer()`

Advances to the next scheduled timer.

## Clear all timers without executing

`jest.clearAllTimers()`

Removes all pending timers from the queue.

## Get count of pending timers

`jest.getTimerCount()`

Returns the number of timers waiting to execute.

## Test setTimeout behavior

`advanceTimersByTime()`

```typescript
function delayedCall(callback: () => void) {
  setTimeout(callback, 1000);
}

test('setTimeout', () => {
  jest.useFakeTimers();
  const callback = jest.fn();

  delayedCall(callback);

  expect(callback).not.toHaveBeenCalled();

  jest.advanceTimersByTime(1000);

  expect(callback).toHaveBeenCalledTimes(1);
});
```

## Configure fake timer options

`jest.useFakeTimers(options)`

```typescript
jest.useFakeTimers({
  advanceTimers: true,                     // Auto-advance timers
  doNotFake: ['nextTick', 'setImmediate'], // Exclude specific APIs
  now: new Date('2024-01-01'),             // Set system time
  timerLimit: 100,                         // Max timers to run
});
```

## Set system time

`jest.setSystemTime(date)`

```typescript
jest.setSystemTime(new Date('2024-06-15'));
```

## Mix timers with promises

`Promise.resolve()`

```typescript
test('timers with async', async () => {
  jest.useFakeTimers();

  const promise = asyncWithDelay();

  jest.advanceTimersByTime(1000);
  await Promise.resolve(); // Flush promise queue

  const result = await promise;
  expect(result).toBe('done');
});
```
