# Firestore Triggers

Testing Firestore document triggers (onCreate, onUpdate, onDelete).

## Test onCreate trigger in online mode

`testEnv.firestore.makeDocumentSnapshot(data, path)`

Online mode connects to real Firebase. Create snapshots with test data.

```typescript
import firebaseFunctionsTest from 'firebase-functions-test';
import * as admin from 'firebase-admin';
import { onUserCreate } from '../src/index';

const testEnv = firebaseFunctionsTest({
  projectId: 'test-project',
}, './service-account.json');

describe('onUserCreate', () => {
  afterAll(() => testEnv.cleanup());

  test('creates profile document', async () => {
    const wrapped = testEnv.wrap(onUserCreate);

    const userId = 'test-user-123';
    const snap = testEnv.firestore.makeDocumentSnapshot(
      { name: 'Test User', email: 'test@example.com' },
      `users/${userId}`
    );

    const context = { params: { userId } };

    await wrapped(snap, context);

    const profile = await admin.firestore().doc(`profiles/${userId}`).get();
    expect(profile.exists).toBe(true);
    expect(profile.data()?.displayName).toBe('Test User');
  });
});
```

## Test onCreate trigger in offline mode

`jest.mock('firebase-admin')`

Offline mode requires mocking firebase-admin before importing functions.

```typescript
import firebaseFunctionsTest from 'firebase-functions-test';

const testEnv = firebaseFunctionsTest();

const mockSet = jest.fn().mockResolvedValue(undefined);
jest.mock('firebase-admin', () => ({
  initializeApp: jest.fn(),
  firestore: jest.fn(() => ({
    doc: jest.fn(() => ({ set: mockSet })),
    FieldValue: { serverTimestamp: jest.fn() },
  })),
}));

import * as admin from 'firebase-admin';
import { onUserCreate } from '../src/index';

describe('onUserCreate offline', () => {
  beforeEach(() => jest.clearAllMocks());
  afterAll(() => testEnv.cleanup());

  test('calls firestore set with correct data', async () => {
    const wrapped = testEnv.wrap(onUserCreate);

    const snap = {
      data: () => ({ name: 'Test', email: 'test@test.com' }),
      id: 'user-123',
    };

    await wrapped(snap, { params: { userId: 'user-123' } });

    expect(admin.firestore().doc).toHaveBeenCalledWith('profiles/user-123');
    expect(mockSet).toHaveBeenCalledWith(
      expect.objectContaining({ displayName: 'Test' })
    );
  });
});
```

## Test onUpdate trigger

`testEnv.makeChange(beforeSnap, afterSnap)`

Create a Change object from before and after snapshots.

```typescript
describe('onProfileUpdate', () => {
  test('detects email change', async () => {
    const wrapped = testEnv.wrap(onProfileUpdate);

    const beforeSnap = testEnv.firestore.makeDocumentSnapshot(
      { email: 'old@test.com', name: 'User' },
      'profiles/profile-123'
    );

    const afterSnap = testEnv.firestore.makeDocumentSnapshot(
      { email: 'new@test.com', name: 'User' },
      'profiles/profile-123'
    );

    const change = testEnv.makeChange(beforeSnap, afterSnap);
    const context = { params: { profileId: 'profile-123' } };

    const consoleSpy = jest.spyOn(console, 'log');
    await wrapped(change, context);

    expect(consoleSpy).toHaveBeenCalledWith(
      'Email changed for profile-123'
    );
  });
});
```

## Test onDelete trigger

`testEnv.firestore.makeDocumentSnapshot(data, path)`

Same snapshot creation as onCreate, but triggers cleanup logic.

```typescript
describe('onUserDelete', () => {
  test('cleans up related data', async () => {
    const wrapped = testEnv.wrap(onUserDelete);

    const snap = testEnv.firestore.makeDocumentSnapshot(
      { name: 'Deleted User' },
      'users/user-to-delete'
    );

    await wrapped(snap, { params: { userId: 'user-to-delete' } });

    // Assert cleanup happened
  });
});
```

## Provide context with path parameters

`{ params: { userId: 'value' } }`

Match the parameter names from the function's document path definition.

```typescript
// Function defined with: .document('users/{userId}')
const context = { params: { userId: 'user-123' } };

// Function defined with: .document('orders/{orderId}/items/{itemId}')
const context = { params: { orderId: 'order-1', itemId: 'item-1' } };
```

## Create minimal snapshot for offline tests

`{ data: () => ({...}), id }`

When not using makeDocumentSnapshot, provide the minimal interface.

```typescript
const snap = {
  data: () => ({ name: 'Test', status: 'active' }),
  id: 'doc-123',
  ref: { path: 'collection/doc-123' },
  exists: true,
};
```
