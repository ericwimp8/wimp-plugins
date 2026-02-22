# Auth and Scheduled Functions

Testing Firebase Auth triggers and scheduled (Pub/Sub) functions.

## Test auth onCreate trigger

`testEnv.auth.makeUserRecord(data)`

Create a mock user record for auth trigger testing.

```typescript
import firebaseFunctionsTest from 'firebase-functions-test';
import { onUserSignup } from '../src/index';

const testEnv = firebaseFunctionsTest({
  projectId: 'test-project',
}, './service-account.json');

describe('onUserSignup', () => {
  afterAll(() => testEnv.cleanup());

  test('creates user document', async () => {
    const wrapped = testEnv.wrap(onUserSignup);

    const user = testEnv.auth.makeUserRecord({
      uid: 'test-uid-123',
      email: 'test@example.com',
      displayName: 'Test User',
    });

    await wrapped(user);

    const doc = await admin.firestore().doc('users/test-uid-123').get();
    expect(doc.exists).toBe(true);
    expect(doc.data()?.email).toBe('test@example.com');
  });
});
```

## Test auth onDelete trigger

`testEnv.auth.makeUserRecord(data)`

Same user record creation, but tests cleanup logic.

```typescript
describe('onUserDelete', () => {
  test('removes user data on account deletion', async () => {
    const wrapped = testEnv.wrap(onUserDelete);

    const user = testEnv.auth.makeUserRecord({
      uid: 'deleted-user-123',
      email: 'deleted@example.com',
    });

    await wrapped(user);

    // Verify cleanup
  });
});
```

## Create user record with provider data

`providerData: [...]`

Include provider information for OAuth users.

```typescript
const googleUser = testEnv.auth.makeUserRecord({
  uid: 'google-123',
  email: 'user@gmail.com',
  displayName: 'Google User',
  photoURL: 'https://example.com/photo.jpg',
  providerData: [{
    providerId: 'google.com',
    uid: 'google-uid',
    email: 'user@gmail.com',
  }],
});
```

## Test scheduled function

`testEnv.wrap(scheduledFunction)`

Scheduled functions receive an empty context object.

```typescript
describe('dailyCleanup', () => {
  test('executes cleanup', async () => {
    const wrapped = testEnv.wrap(dailyCleanup);

    const consoleSpy = jest.spyOn(console, 'log');
    await wrapped({});

    expect(consoleSpy).toHaveBeenCalledWith('Running daily cleanup');
  });
});
```

## Test scheduled function with side effects

`mockFirestore operations`

Verify the scheduled function performs expected database operations.

```typescript
describe('dailyReport', () => {
  test('generates and saves report', async () => {
    const mockSet = jest.fn().mockResolvedValue(undefined);
    (admin.firestore().doc as jest.Mock).mockReturnValue({ set: mockSet });

    const wrapped = testEnv.wrap(dailyReport);
    await wrapped({});

    expect(mockSet).toHaveBeenCalledWith(
      expect.objectContaining({
        generatedAt: expect.anything(),
        type: 'daily',
      })
    );
  });
});
```

## Test Pub/Sub triggered function

`wrapped(message, context)`

Pub/Sub functions receive a message object with data and attributes.

```typescript
describe('onPubSubMessage', () => {
  test('processes message data', async () => {
    const wrapped = testEnv.wrap(onPubSubMessage);

    const message = {
      data: Buffer.from(JSON.stringify({ action: 'process' })).toString('base64'),
      attributes: { source: 'test' },
    };

    await wrapped(message, {});

    // Verify message was processed
  });
});
```

## Decode Pub/Sub message data

`Buffer.from(message.data, 'base64').toString()`

Pub/Sub messages are base64 encoded.

```typescript
test('decodes message correctly', async () => {
  const payload = { userId: '123', action: 'notify' };
  const message = {
    data: Buffer.from(JSON.stringify(payload)).toString('base64'),
  };

  const wrapped = testEnv.wrap(processMessage);
  await wrapped(message, {});

  // Function internally decodes and processes payload
});
```
