# Module Mocking

Mocking entire modules, partial mocks, and spying on methods.

## Auto-mock an entire module

`jest.mock('./path/to/module')`

```typescript
jest.mock('./path/to/module');

import { someFunction } from './path/to/module';

test('uses mocked module', () => {
  (someFunction as jest.Mock).mockReturnValue('mocked');
  expect(someFunction()).toBe('mocked');
});
```

## Mock module with factory function

`jest.mock(path, factory)`

```typescript
jest.mock('./path/to/module', () => ({
  namedExport: jest.fn(),
  default: jest.fn(),
}));
```

## Mock only specific exports (partial mock)

`jest.requireActual()`

```typescript
jest.mock('./path/to/module', () => {
  const original = jest.requireActual('./path/to/module');
  return {
    ...original,
    functionToMock: jest.fn(),
  };
});
```

## Mock default export

`__esModule: true`

```typescript
jest.mock('./module', () => ({
  __esModule: true,
  default: jest.fn(() => 'mocked default'),
}));
```

## Get type-safe mock reference

`jest.mocked(fn)`

```typescript
import { someFunction } from './module';

jest.mock('./module');

const mockedFn = jest.mocked(someFunction);

test('type-safe mock', () => {
  mockedFn.mockReturnValue('typed return');
  expect(mockedFn()).toBe('typed return');
});
```

## Alternative: type assertion for mocks

`as jest.MockedFunction<typeof fn>`

```typescript
const mockedFn = someFunction as jest.MockedFunction<typeof someFunction>;
```

## Spy on object method

`jest.spyOn(object, 'method')`

```typescript
const video = {
  play: () => true,
  pause: () => false,
};

test('spy on method', () => {
  const spy = jest.spyOn(video, 'play');
  video.play();
  expect(spy).toHaveBeenCalled();
  spy.mockRestore();
});
```

## Spy on static class method

`jest.spyOn(Class, 'staticMethod')`

```typescript
class MyClass {
  static staticMethod() { return 'static'; }
}

jest.spyOn(MyClass, 'staticMethod');
```

## Spy on instance method for all instances

`jest.spyOn(Class.prototype, 'method')`

```typescript
class MyClass {
  instanceMethod() { return 'instance'; }
}

jest.spyOn(MyClass.prototype, 'instanceMethod');
```

## Spy on getter

`jest.spyOn(obj, 'prop', 'get')`

```typescript
jest.spyOn(MyClass.prototype, 'someGetter', 'get');
```

## Spy on setter

`jest.spyOn(obj, 'prop', 'set')`

```typescript
jest.spyOn(MyClass.prototype, 'someSetter', 'set');
```

## Override spy implementation

`spyOn().mockImplementation()`

```typescript
const spy = jest.spyOn(obj, 'method').mockImplementation(() => 'mocked');
```

## Restore original implementation

`mockRestore()`

```typescript
spy.mockRestore();

// Or restore all spies
jest.restoreAllMocks();
```
