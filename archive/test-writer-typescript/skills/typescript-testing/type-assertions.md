# Type Assertions in Tests

Type-level testing validates what the compiler infers. Runtime assertions verify actual values. Neither alone provides complete coverage.

## Validate type equality at compile time

`Expect<Equal<X, Y>>`

Framework-agnostic utilities that error during `tsc` if types don't match:

```typescript
type Expect<T extends true> = T;
type Equal<X, Y> =
  (<T>() => T extends X ? 1 : 2) extends (<T>() => T extends Y ? 1 : 2)
    ? true
    : false;

// Validates at compile time
type _test = Expect<Equal<typeof result, ExpectedType>>;
```

Additional utilities:

```typescript
type NotEqual<X, Y> = Equal<X, Y> extends true ? false : true;
type IsAny<T> = 0 extends 1 & T ? true : false;
type IsNever<T> = [T] extends [never] ? true : false;

type _tests = [
  Expect<Equal<string, string>>,
  Expect<NotEqual<string, number>>,
  Expect<IsAny<any>>,
  Expect<IsNever<never>>,
];
```

## Test types without runtime values

`declare const value: Type`

Use `declare const` for type-only testing without creating runtime values:

```typescript
declare const state: ApplicationState;
expectTypeOf(getUser(state, 'id-123')).toEqualTypeOf<User | undefined>();
```

## Assert types with expectTypeOf

`expectTypeOf<T>().toEqualTypeOf<U>()`

Fluent API for type assertions (Vitest or expect-type package):

```typescript
import { expectTypeOf } from 'vitest';

// Basic checks
expectTypeOf<string>().toBeString();
expectTypeOf<any>().toBeAny();
expectTypeOf<never>().toBeNever();

// Object equality
expectTypeOf({ a: 1 }).toEqualTypeOf<{ a: number }>();
expectTypeOf({ a: 1, b: 2 }).not.toEqualTypeOf<{ a: number }>();

// Function signatures
const fn = (a: number, b: string) => ({ a, b });
expectTypeOf(fn).parameter(0).toBeNumber();
expectTypeOf(fn).parameter(1).toBeString();
expectTypeOf(fn).returns.toEqualTypeOf<{ a: number; b: string }>();

// Promise resolution
expectTypeOf(Promise.resolve(42)).resolves.toBeNumber();

// Union manipulation
type Status = 'loading' | 'success' | 'error';
expectTypeOf<Status>().extract<'success'>().toEqualTypeOf<'success'>();
expectTypeOf<Status>().exclude<'loading'>().toEqualTypeOf<'success' | 'error'>();
```

## Test that code should not compile

`@ts-expect-error`

Use `@ts-expect-error` for negative type testing. The comment must precede code that actually errors:

```typescript
// @ts-expect-error - primitive not assignable to object constraint
stringify('not an object');

// @ts-expect-error - types are not equal
type _fail = Expect<Equal<string, number>>;
```

## Validate fixtures while preserving literal types

`satisfies Config`

The `satisfies` operator (TS 4.9+) validates type constraints while preserving literal inference:

```typescript
const testConfig = {
  apiUrl: 'https://test.api.com',
  timeout: 5000,
} satisfies Config;

// Literal types preserved:
testConfig.apiUrl;  // Type: "https://test.api.com" (not string)
testConfig.timeout; // Type: 5000 (not number)
```

Comparison with alternatives:

```typescript
// as - bypasses checking (unsafe)
const bad = { wrong: true } as Config;  // No error!

// : Type - widens types
const widened: Config = { apiUrl: 'test', timeout: 5000 };
widened.apiUrl;  // Type: string (not 'test')

// satisfies - validates AND preserves narrow types
const best = { apiUrl: 'test', timeout: 5000 } satisfies Config;
best.apiUrl;  // Type: 'test'
```

## Cast mock functions with type safety

`as jest.MockedFunction<typeof fn>`

Acceptable assertion for typing mocks when framework requires it:

```typescript
const mockFn = jest.fn() as jest.MockedFunction<typeof originalFn>;

// DOM elements in tests
const element = document.querySelector('.btn') as HTMLButtonElement;
```

Avoid using `as` to silence legitimate type errors:

```typescript
// ❌ Hides real bugs
const badData = { wrong: 'shape' } as User;
```
