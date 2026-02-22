# Common Pitfalls

Anti-patterns that cause tests to provide false confidence. Each pitfall shows incorrect and correct approaches.

## Avoid using `any` to bypass type errors

`Partial<T>` or `Pick<T, K>` instead of `any`

Using `any` defeats type checking entirely:

```typescript
// ❌ Missing required fields not caught
const mockUser = { name: "Test User" } as any;
fetchUserData(mockUser);

// ✅ Type-safe partial
const mockUser: Partial<User> = { name: "Test User", id: "123" };

// ✅ Or Pick for specific fields
function getUserName(user: Pick<User, 'name'>) { return user.name; }
```

## Avoid incorrect type assertions hiding bugs

`satisfies` or proper fixtures instead of `as`

Assertions bypass type checking:

```typescript
// ❌ Missing required fields
const response = { data: { userId: 1 } } as ApiResponse<User>;

// ✅ Create proper test fixtures
const response: ApiResponse<User> = {
  status: 200,
  data: { userId: 1, name: "Test", email: "test@test.com" },
  error: null
};
```

## Avoid testing implementation details

`customer.canCheckout()` not `customer._internalId`

Test behavior, not internals:

```typescript
// ❌ Magic number, internal detail
expect(customer.type).toBe(1);
expect(customer._internalId).toBeDefined();

// ✅ Test behavior
expect(customer.isRegistered()).toBe(true);
expect(customer.canCheckout()).toBe(true);
```

## Avoid type widening in test values

`as const` or explicit union types

Widened types allow invalid assignments:

```typescript
// ❌ Type is 'string', not 'loading'
let status = "loading";
status = "invalid_status";  // No error!

// ✅ Preserve literal type
const status = "loading" as const;
// OR
let status: "loading" | "success" | "error" = "loading";
```

## Avoid over-mocking creating tautological tests

`Mock only external boundaries`

Testing mock setup, not real behavior:

```typescript
// ❌ Testing the mock
test('processes payment', async () => {
  const mockValidator = jest.fn().mockReturnValue(true);
  const mockGateway = jest.fn().mockResolvedValue({ success: true });

  const result = await processPayment(mockValidator, mockGateway);

  expect(mockValidator).toHaveBeenCalled();  // Just tests mock was called
  expect(result).toBe(true);  // Always true because we set it up that way
});

// ✅ Mock only external boundaries
test('processes valid payment', async () => {
  nock('https://api.stripe.com').post('/charges').reply(200, { id: 'ch_123' });

  const result = await paymentService.processPayment({
    amount: 1000,
    currency: 'usd',
    cardToken: 'tok_visa'
  });

  expect(result.success).toBe(true);
  expect(result.chargeId).toBe('ch_123');
});
```

## Avoid forgetting to await promises

`expect.assertions(n)` for safety

Unawaited promises create false positives:

```typescript
// ❌ Promise not awaited - assertion never runs
test('should not pass', () => {
  const p = Promise.resolve(false);
  p.then(value => {
    expect(value).toBe(true);  // Never executes before test ends
  });
});

// ✅ Await the promise
test('fetches data', async () => {
  expect.assertions(1);
  const data = await fetchData();
  expect(data).toBeDefined();
});
```

## Avoid double assertions hiding design issues

`unknown as Type` is a code smell

Double assertions indicate design problems:

```typescript
// ❌ Code smell
const value = someValue as unknown as DesiredType;

// This indicates:
// - Type definitions are wrong
// - Design needs refactoring
// - Runtime validation is needed
```

## Avoid mocking private methods

`Test through public interface`

Mocking privates tests implementation, not behavior:

```typescript
// ❌ Testing internal implementation
(userService as any).validateEmail = jest.fn().mockReturnValue(true);

// ✅ Test through public interface
test('rejects invalid email', () => {
  expect(() => userService.createUser('invalid')).toThrow('Invalid');
});
test('accepts valid email', async () => {
  const user = await userService.createUser('test@example.com');
  expect(user).toBeDefined();
});
```

## Avoid test files excluded from compilation

`tsconfig.test.json extends base`

Test files not type-checked:

```typescript
// ❌ Tests excluded from type checking
// tsconfig.json: { "include": ["src/**/*"], "exclude": ["**/*.test.ts"] }

// ✅ Separate test config
// tsconfig.test.json
{
  "extends": "./tsconfig.json",
  "compilerOptions": { "types": ["jest", "node"], "noEmit": true },
  "include": ["src/**/*", "tests/**/*", "**/*.test.ts"]
}
```

## Avoid path alias issues in tests

`moduleNameMapper in jest.config`

Path aliases work in IDE but fail in tests:

```typescript
// ❌ Path aliases not configured for Jest
// tsconfig.json: { "paths": { "@/*": ["src/*"] } }

// ✅ Configure Jest module mapper
// jest.config.ts
export default {
  moduleNameMapper: { '^@/(.*)$': '<rootDir>/src/$1' }
};
```

## Avoid ESM vs CommonJS issues

`transformIgnorePatterns` or Vitest

ESM modules fail to transform:

```typescript
// ✅ Transform ESM to CJS
// jest.config.ts
export default {
  transformIgnorePatterns: ['node_modules/(?!(esm-package)/)']
};

// OR use --experimental-vm-modules
// package.json: { "scripts": { "test": "NODE_OPTIONS='--experimental-vm-modules' jest" } }

// OR use Vitest (native ESM support)
```

## Avoid testing only happy paths at boundaries

`Test invalid input from external sources`

Type boundaries need runtime validation:

```typescript
// ❌ Only happy path
test('parses user', () => {
  const user = parseUser({ name: "Test", age: 25 });
  expect(user.name).toBe("Test");
});

// ✅ Test boundaries
test('handles invalid input types', () => {
  expect(() => parseUser(null)).toThrow();
  expect(() => parseUser({ name: 123 })).toThrow(TypeError);

  // Test runtime type mismatches from external sources
  const externalData = JSON.parse('{"name": null}');
  expect(() => parseUser(externalData)).toThrow();
});
```

## Use runtime validation at external boundaries

`zod.parse()` or similar

TypeScript types don't exist at runtime:

```typescript
// ❌ No runtime validation
const data = response.json() as any;
processUser(data);

// ✅ Runtime validation
import { z } from 'zod';
const UserSchema = z.object({ id: z.string(), name: z.string() });
const data = UserSchema.parse(await response.json());  // Validates at runtime
```
