# Callable Functions

Testing Firebase Cloud Functions callable triggers (onCall).

## Wrap callable function for testing

`testEnv.wrap(callableFunction)`

The wrap method creates a test-invocable version of the function.

```typescript
import firebaseFunctionsTest from 'firebase-functions-test';
import { addNumbers } from '../src/index';

const testEnv = firebaseFunctionsTest();

describe('addNumbers', () => {
  afterAll(() => testEnv.cleanup());

  test('adds numbers for authenticated user', async () => {
    const wrapped = testEnv.wrap(addNumbers);

    const data = { a: 5, b: 3 };
    const context = {
      auth: {
        uid: 'test-user-id',
        token: { email: 'test@example.com' },
      },
    };

    const result = await wrapped(data, context);
    expect(result.sum).toBe(8);
  });
});
```

## Test unauthenticated access

`wrapped(data)` without context

Omit the context argument to simulate unauthenticated calls.

```typescript
test('throws for unauthenticated user', async () => {
  const wrapped = testEnv.wrap(addNumbers);

  await expect(wrapped({ a: 1, b: 2 }))
    .rejects.toThrow('unauthenticated');
});
```

## Create authenticated context

`{ auth: { uid, token } }`

Simulate a logged-in user with uid and token claims.

```typescript
const authenticatedContext = {
  auth: {
    uid: 'user-123',
    token: {
      email: 'user@example.com',
      email_verified: true,
      firebase: {
        sign_in_provider: 'password',
      },
    },
  },
};
```

## Create admin context with custom claims

`token: { admin: true }`

Test functions that check custom claims like admin privileges.

```typescript
const adminContext = {
  auth: {
    uid: 'admin-123',
    token: {
      email: 'admin@example.com',
      admin: true,
    },
  },
};

test('allows admin access', async () => {
  const wrapped = testEnv.wrap(adminOnlyFunction);
  const result = await wrapped({ action: 'delete' }, adminContext);
  expect(result.success).toBe(true);
});
```

## Test HttpsError responses

`functions.https.HttpsError`

Callable functions throw HttpsError for client-visible errors.

```typescript
test('throws permission-denied for non-admin', async () => {
  const wrapped = testEnv.wrap(adminOnlyFunction);
  const userContext = {
    auth: { uid: 'user-1', token: { admin: false } },
  };

  await expect(wrapped({ action: 'delete' }, userContext))
    .rejects.toThrow('permission-denied');
});
```

## Test with different auth providers

`sign_in_provider: 'google.com'`

Simulate users from different authentication providers.

```typescript
const googleAuthContext = {
  auth: {
    uid: 'google-user',
    token: {
      email: 'user@gmail.com',
      firebase: {
        sign_in_provider: 'google.com',
      },
    },
  },
};

const anonymousContext = {
  auth: {
    uid: 'anon-123',
    token: {
      firebase: {
        sign_in_provider: 'anonymous',
      },
    },
  },
};
```
