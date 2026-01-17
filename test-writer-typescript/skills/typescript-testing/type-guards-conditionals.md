# Type Guards and Conditional Types

Testing type guards requires verifying both runtime behavior and type narrowing effect. Testing conditional types requires verifying resolution across different inputs.

## Test type guard runtime behavior

`expect(isType(value)).toBe(true)`

Type guards must be tested for correct boolean return values:

```typescript
interface Cat { meow(): void; whiskers: number; }
interface Dog { bark(): void; friendly: boolean; }
type Pet = Cat | Dog;

function isCat(pet: Pet): pet is Cat {
  return 'meow' in pet;
}

test('isCat returns correct boolean', () => {
  const cat: Cat = { meow: () => {}, whiskers: 12 };
  const dog: Dog = { bark: () => {}, friendly: true };

  expect(isCat(cat)).toBe(true);
  expect(isCat(dog)).toBe(false);
});
```

## Test type guard narrowing effect

`expectTypeOf(pet).toEqualTypeOf<Cat>()`

Verify the type narrows correctly in conditional branches:

```typescript
test('isCat narrows Pet to Cat', () => {
  const pet: Pet = { meow: () => {}, whiskers: 12 };

  if (isCat(pet)) {
    expectTypeOf(pet).toEqualTypeOf<Cat>();
    expectTypeOf(pet.whiskers).toBeNumber();
  } else {
    expectTypeOf(pet).toEqualTypeOf<Dog>();
  }
});
```

## Verify type guard signature

`expectTypeOf(guard).guards.toEqualTypeOf<T>()`

Test the guard signature directly:

```typescript
test('isCat has correct guard signature', () => {
  expectTypeOf(isCat).guards.toEqualTypeOf<Cat>();
});
```

## Test assertion functions

`expectTypeOf(fn).asserts.toBeString()`

Assertion functions use the `asserts` keyword for type narrowing:

```typescript
function assertIsString(value: unknown): asserts value is string {
  if (typeof value !== 'string') {
    throw new TypeError('Expected string');
  }
}

test('assertIsString asserts string type', () => {
  expectTypeOf(assertIsString).asserts.toBeString();
});
```

Create reusable assertion utilities:

```typescript
function assertDefined<T>(
  value: T | null | undefined,
  message?: string
): asserts value is T {
  if (value === null || value === undefined) {
    throw new Error(message ?? 'Expected value to be defined');
  }
}

test('user service returns valid user', async () => {
  const result = await userService.findById(1);

  assertDefined(result, 'User should exist');
  // TypeScript now knows result is non-null
  expect(result.name).toBe('Expected Name');
});
```

## Test conditional type resolution

`Expect<Equal<ConditionalType<Input>, Expected>>`

Verify conditional types resolve correctly for different inputs:

```typescript
type IsArray<T> = T extends any[] ? true : false;
type Flatten<T> = T extends (infer U)[] ? U : T;

type _tests = [
  Expect<Equal<IsArray<number[]>, true>>,
  Expect<Equal<IsArray<number>, false>>,
  Expect<Equal<Flatten<string[]>, string>>,
  Expect<Equal<Flatten<number>, number>>,
];

// Runtime-friendly with expectTypeOf
test('Flatten extracts array element type', () => {
  expectTypeOf<Flatten<string[]>>().toEqualTypeOf<string>();
  expectTypeOf<Flatten<number>>().toEqualTypeOf<number>();
});
```

## Test distributive behavior over unions

`expectTypeOf<Type<A | B>>().toEqualTypeOf<Type<A> | Type<B>>()`

Conditional types distribute over unions when the type parameter is naked:

```typescript
type ToArray<T> = T extends any ? T[] : never;

test('ToArray distributes over unions', () => {
  // Distributes: ToArray<string | number> = string[] | number[]
  expectTypeOf<ToArray<string | number>>().toEqualTypeOf<string[] | number[]>();
  // NOT equal to (string | number)[]
  expectTypeOf<ToArray<string | number>>().not.toEqualTypeOf<(string | number)[]>();
});
```

## Test discriminated union narrowing

`result.status === 'success'`

Verify narrowing per discriminant and exhaustiveness:

```typescript
type Result<T, E> =
  | { status: 'success'; data: T }
  | { status: 'error'; error: E }
  | { status: 'loading' };

test('Result type narrows correctly', () => {
  const success: Result<number, string> = { status: 'success', data: 42 };

  if (success.status === 'success') {
    expectTypeOf(success.data).toBeNumber();
    // @ts-expect-error - error property doesn't exist on success branch
    success.error;
  }
});

test('Result union is exhaustive', () => {
  type StatusValues = Result<any, any>['status'];
  expectTypeOf<StatusValues>().toEqualTypeOf<'success' | 'error' | 'loading'>();
});
```

Exhaustiveness check pattern:

```typescript
function handleResult<T, E>(result: Result<T, E>): string {
  switch (result.status) {
    case 'success': return `Data: ${result.data}`;
    case 'error': return `Error: ${result.error}`;
    case 'loading': return 'Loading...';
    default:
      // Type should be `never` if all cases handled
      const _exhaustive: never = result;
      return _exhaustive;
  }
}
```

## Test mapped type transformations

`expectTypeOf<MappedType<T>>().toEqualTypeOf<Expected>()`

Verify key remapping and value transformations:

```typescript
type Getters<T> = {
  [K in keyof T as `get${Capitalize<string & K>}`]: () => T[K];
};

interface User { id: string; name: string; }

test('Getters remaps keys with get prefix', () => {
  type UserGetters = Getters<User>;

  expectTypeOf<UserGetters>().toEqualTypeOf<{
    getId: () => string;
    getName: () => string;
  }>();
});
```

## Test template literal types

`expectTypeOf<EventName<'click'>>().toEqualTypeOf<'onClick'>()`

Verify string pattern transformations:

```typescript
type EventName<T extends string> = `on${Capitalize<T>}`;

test('EventName creates event handler names', () => {
  expectTypeOf<EventName<'click'>>().toEqualTypeOf<'onClick'>();
  expectTypeOf<EventName<'submit'>>().toEqualTypeOf<'onSubmit'>();
});
```

## Test generic type preservation

`expectTypeOf(identity('hello')).toEqualTypeOf<'hello'>()`

Verify generics preserve literal types without widening:

```typescript
function identity<T>(value: T): T {
  return value;
}

test('identity preserves literal types', () => {
  const result = identity('hello');

  expect(result).toBe('hello');
  // Literal type "hello" preserved, not widened to string
  expectTypeOf(result).toEqualTypeOf<'hello'>();
  expectTypeOf(identity(42)).toEqualTypeOf<42>();
});
```

Test constrained generics:

```typescript
function stringify<T extends object>(obj: T): string {
  return JSON.stringify(obj);
}

test('stringify enforces object constraint', () => {
  expectTypeOf(stringify).parameter(0).toExtend<object>();

  // @ts-expect-error - primitive not assignable to object constraint
  stringify('not an object');
});
```
