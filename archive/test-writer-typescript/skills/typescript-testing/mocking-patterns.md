# Mocking Patterns

Type-safe mocking preserves compile-time checks while enabling test isolation. Mock only at system boundaries—database, network, filesystem, time.

## Create typed mock objects with defaults

`createMockUser(overrides: Partial<User>): User`

Factory functions with `Partial<T>` for type-safe test data:

```typescript
interface User {
  id: string;
  firstName: string;
  lastName: string;
  email: string;
  profile: { avatar: string; bio: string };
}

function createMockUser(overrides: Partial<User> = {}): User {
  const defaults: User = {
    id: '1',
    firstName: 'John',
    lastName: 'Doe',
    email: 'john@example.com',
    profile: { avatar: '', bio: '' }
  };
  return { ...defaults, ...overrides };
}

// Only specify what matters for the test
const mockUser = createMockUser({ firstName: 'Jane', lastName: 'Smith' });
```

## Handle deeply nested mock objects

`DeepPartial<T>`

For nested objects, define a recursive partial type:

```typescript
type DeepPartial<T> = T extends Function
  ? T
  : T extends Array<infer U>
  ? Array<DeepPartial<U>>
  : T extends object
  ? { [K in keyof T]?: DeepPartial<T[K]> }
  : T | undefined;

function createMockConfig(overrides: DeepPartial<Config> = {}): Config {
  // Deep merge implementation
}
```

## Type mock functions preserving signatures

`jest.MockedFunction<typeof fn>`

Preserve full type information on mocked functions:

```typescript
export function mockFunction<T extends (...args: any[]) => any>(
  fn: T
): jest.MockedFunction<T> {
  return fn as jest.MockedFunction<T>;
}

const sterlingToEurosMock = mockFunction(sterlingToEuros);
sterlingToEurosMock.mockReturnValue(50);    // OK - returns number
sterlingToEurosMock.mockReturnValue("50");  // Error - wrong type
```

For module mocking (Jest 27.4+):

```typescript
import { myModule } from './myModule';
jest.mock('./myModule');

const mockedModule = jest.mocked(myModule, { shallow: false });
mockedModule.someMethod.mockReturnValue('test');
```

## Create partial mocks with runtime protection

`Proxy handler throws on unmocked access`

Error if unmocked properties are accessed:

```typescript
function mockPartially<T extends object>(mockedProperties: Partial<T> = {}): T {
  const handler = {
    get(target: T, prop: keyof T & string) {
      if (prop in mockedProperties) {
        return mockedProperties[prop];
      }
      throw new Error(`Mock does not implement property: ${prop}`);
    },
  };
  return new Proxy<T>({} as T, handler);
}

const server = mockPartially<Server>({
  daily: 1,
  memory: 4,
});
// server.unmockedProp throws Error
```

## Use constructor injection for testability

`constructor(private dep: Dependency = realDep)`

Make dependencies swappable via constructor:

```typescript
export interface ValueGetter {
  getValue(param: string): string;
}

export class Getter {
  constructor(
    private a: (param: string) => string = externalA,
    private b: (param: string) => string = externalB,
    private c: ValueGetter = new C()
  ) {}

  getAll(param: string): string[] {
    return [this.a(param), this.b(param), this.c.getValue(param)];
  }
}

test('can be mocked using dependency injection', () => {
  const mockA = () => 'x';
  const mockB = () => 'y';
  const mockC = { getValue: () => 'z' };

  const getter = new Getter(mockA, mockB, mockC);
  expect(getter.getAll('')).toEqual(['x', 'y', 'z']);
});
```

## Implement interface-based mocking

`implements PublicInterface<T>`

Extract public interface for mock implementations:

```typescript
type PublicInterface<T> = Pick<T, keyof T>;

class MockTodosApiService implements PublicInterface<TodosApiService> {
  getTodo = jest.fn().mockReturnValue(of({ id: 1, title: 'Test' }));
  createTodo = jest.fn().mockReturnValue(of(1));
  updateTodo = jest.fn().mockReturnValue(of(void 0));
}
```

## Abstract third-party dependencies

`interface HttpClient { get<T>(url: string): Promise<T> }`

Create abstractions instead of mocking third-party APIs directly:

```typescript
// ❌ Breaks when axios API changes
jest.mock('axios');
const mockedAxios = axios as jest.Mocked<typeof axios>;

// ✅ Mock your interface
interface HttpClient {
  get<T>(url: string): Promise<T>;
}

class AxiosHttpClient implements HttpClient {
  async get<T>(url: string): Promise<T> {
    const response = await axios.get(url);
    return response.data;
  }
}

const mockClient: HttpClient = { get: jest.fn() };
```

## Reset mocks between tests

`jest.clearAllMocks()`

Prevent state leakage:

```typescript
// In jest.config.js
{ clearMocks: true, resetMocks: true, restoreMocks: true }

// Or in test file
afterEach(() => { jest.clearAllMocks(); });
```

Without reset:

```typescript
it('first test', () => { mockFn('first'); expect(mockFn).toHaveBeenCalledTimes(1); });
it('second test', () => { mockFn('second'); expect(mockFn).toHaveBeenCalledTimes(1); }); // FAILS - still has call from first test
```

## Type mocked services properly

`{ [K in keyof Service]: jest.Mock<Service[K]> }`

Catch typos and type errors in mock setup:

```typescript
// ❌ Typo not caught
const mockService = { getUser: jest.fn() };
mockService.getUser.mockReturnValue({ nam: "Test" });

// ✅ Typo caught
type MockedService = { [K in keyof UserService]: jest.Mock<UserService[K]> };
const mockService: MockedService = {
  getUser: jest.fn<UserService['getUser']>()
};
mockService.getUser.mockResolvedValue({ name: "Test" });
```
