# Mocking Fundamentals

Creating and using mock functions with jest.fn().

## Create a basic mock function

`jest.fn()`

```typescript
const mockFn = jest.fn();
```

## Create mock with implementation

`jest.fn((args) => result)`

```typescript
const mockWithImpl = jest.fn((x: number) => x * 2);
```

## Create mock with fixed return value

`mockReturnValue(value)`

```typescript
const mockWithReturn = jest.fn().mockReturnValue(42);
```

## Create mock that resolves a promise

`mockResolvedValue(value)`

```typescript
const mockAsync = jest.fn().mockResolvedValue({ data: 'test' });
```

## Create mock that rejects a promise

`mockRejectedValue(error)`

```typescript
const mockReject = jest.fn().mockRejectedValue(new Error('fail'));
```

## Assert mock was called

`toHaveBeenCalled()`

```typescript
expect(mockFn).toHaveBeenCalled();
```

## Assert mock call count

`toHaveBeenCalledTimes(n)`

```typescript
expect(mockFn).toHaveBeenCalledTimes(2);
```

## Assert mock called with specific arguments

`toHaveBeenCalledWith(...args)`

```typescript
expect(mockFn).toHaveBeenCalledWith('arg1', 'arg2');
```

## Assert last call arguments

`toHaveBeenLastCalledWith(...args)`

```typescript
expect(mockFn).toHaveBeenLastCalledWith('lastArg');
```

## Assert nth call arguments

`toHaveBeenNthCalledWith(n, ...args)`

```typescript
expect(mockFn).toHaveBeenNthCalledWith(1, 'firstCallArg');
```

## Assert mock return value

`toHaveReturnedWith(value)`

```typescript
expect(mockFn).toHaveReturnedWith(expectedValue);
```

## Access mock call history

`mock.calls`

```typescript
mockFn.mock.calls;      // Array of call arguments
mockFn.mock.results;    // Array of return values
mockFn.mock.instances;  // Array of `this` values
```

## Chain different implementations per call

`mockImplementationOnce()`

```typescript
const mockFn = jest.fn()
  .mockImplementationOnce(() => 'first call')
  .mockImplementationOnce(() => 'second call')
  .mockImplementation(() => 'default');

mockFn(); // 'first call'
mockFn(); // 'second call'
mockFn(); // 'default'
```
