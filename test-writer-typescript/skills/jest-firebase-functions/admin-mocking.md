# Admin Mocking

Complete firebase-admin mocking patterns for offline testing.

## Create complete firebase-admin mock

`__mocks__/firebase-admin.ts`

Place in `__mocks__` folder for automatic Jest discovery.

```typescript
const mockSet = jest.fn().mockResolvedValue(undefined);
const mockGet = jest.fn().mockResolvedValue({ exists: true, data: () => ({}) });
const mockUpdate = jest.fn().mockResolvedValue(undefined);
const mockDelete = jest.fn().mockResolvedValue(undefined);

const mockDoc = jest.fn(() => ({
  set: mockSet,
  get: mockGet,
  update: mockUpdate,
  delete: mockDelete,
}));

const mockWhere = jest.fn().mockReturnThis();
const mockOrderBy = jest.fn().mockReturnThis();
const mockLimit = jest.fn().mockReturnThis();

const mockCollection = jest.fn(() => ({
  doc: mockDoc,
  add: jest.fn().mockResolvedValue({ id: 'mock-id' }),
  where: mockWhere,
  orderBy: mockOrderBy,
  limit: mockLimit,
  get: jest.fn().mockResolvedValue({ docs: [], empty: true }),
}));

const mockFirestore = jest.fn(() => ({
  collection: mockCollection,
  doc: mockDoc,
  batch: jest.fn(() => ({
    set: jest.fn().mockReturnThis(),
    update: jest.fn().mockReturnThis(),
    delete: jest.fn().mockReturnThis(),
    commit: jest.fn().mockResolvedValue(undefined),
  })),
  runTransaction: jest.fn((fn) => fn({
    get: mockGet,
    set: mockSet,
    update: mockUpdate,
    delete: mockDelete,
  })),
}));

(mockFirestore as any).FieldValue = {
  serverTimestamp: jest.fn(() => 'SERVER_TIMESTAMP'),
  increment: jest.fn((n) => ({ _increment: n })),
  arrayUnion: jest.fn((...items) => ({ _arrayUnion: items })),
  arrayRemove: jest.fn((...items) => ({ _arrayRemove: items })),
  delete: jest.fn(() => ({ _delete: true })),
};

const admin = {
  initializeApp: jest.fn(),
  firestore: mockFirestore,
  auth: jest.fn(() => ({
    getUser: jest.fn().mockResolvedValue({ uid: 'mock-uid' }),
    createUser: jest.fn().mockResolvedValue({ uid: 'new-uid' }),
    updateUser: jest.fn().mockResolvedValue({}),
    deleteUser: jest.fn().mockResolvedValue(undefined),
    setCustomUserClaims: jest.fn().mockResolvedValue(undefined),
    verifyIdToken: jest.fn().mockResolvedValue({ uid: 'verified-uid' }),
  })),
  storage: jest.fn(() => ({
    bucket: jest.fn(() => ({
      file: jest.fn(() => ({
        save: jest.fn().mockResolvedValue(undefined),
        delete: jest.fn().mockResolvedValue(undefined),
        getSignedUrl: jest.fn().mockResolvedValue(['https://signed-url.com']),
      })),
    })),
  })),
};

export = admin;
```

## Use the mock in tests

`jest.mock('firebase-admin')`

Import after mocking to get the mocked version.

```typescript
jest.mock('firebase-admin');
import * as admin from 'firebase-admin';

beforeEach(() => {
  jest.clearAllMocks();
});

test('uses mocked firestore', async () => {
  const db = admin.firestore();
  await db.collection('users').doc('123').set({ name: 'test' });

  expect(db.collection).toHaveBeenCalledWith('users');
});
```

## Override mock response for specific test

`mockResolvedValue` / `mockReturnValue`

Customize mock behavior per test case.

```typescript
test('handles document not found', async () => {
  const mockGet = jest.fn().mockResolvedValue({
    exists: false,
    data: () => undefined,
  });

  (admin.firestore().doc as jest.Mock).mockReturnValue({ get: mockGet });

  const result = await getUserById('nonexistent');
  expect(result).toBeNull();
});
```

## Mock query results

`{ docs: [...], empty: false }`

Return mock documents for collection queries.

```typescript
test('handles query results', async () => {
  const mockDocs = [
    { id: '1', data: () => ({ name: 'User 1' }) },
    { id: '2', data: () => ({ name: 'User 2' }) },
  ];

  (admin.firestore().collection('users').get as jest.Mock)
    .mockResolvedValue({ docs: mockDocs, empty: false });

  const users = await getAllUsers();
  expect(users).toHaveLength(2);
});
```

## Mock batch operations

`batch().set().commit()`

Verify batch writes are constructed correctly.

```typescript
test('batch write succeeds', async () => {
  const mockBatch = {
    set: jest.fn().mockReturnThis(),
    commit: jest.fn().mockResolvedValue(undefined),
  };
  (admin.firestore().batch as jest.Mock).mockReturnValue(mockBatch);

  await batchCreateUsers([{ name: 'User1' }, { name: 'User2' }]);

  expect(mockBatch.set).toHaveBeenCalledTimes(2);
  expect(mockBatch.commit).toHaveBeenCalled();
});
```

## Mock transactions

`runTransaction(fn)`

Provide a mock transaction object to the callback.

```typescript
test('transaction updates correctly', async () => {
  const mockTransaction = {
    get: jest.fn().mockResolvedValue({
      exists: true,
      data: () => ({ count: 5 }),
    }),
    update: jest.fn(),
  };

  (admin.firestore().runTransaction as jest.Mock)
    .mockImplementation((fn) => fn(mockTransaction));

  await incrementCounter('counter-1');

  expect(mockTransaction.update).toHaveBeenCalledWith(
    expect.anything(),
    expect.objectContaining({ count: 6 })
  );
});
```

## Mock external API calls

`jest.mock('axios')`

Mock HTTP clients for functions that call external APIs.

```typescript
import axios from 'axios';

jest.mock('axios');
const mockedAxios = axios as jest.Mocked<typeof axios>;

describe('functionWithApiCall', () => {
  test('handles successful API response', async () => {
    mockedAxios.get.mockResolvedValue({ data: { result: 'success' } });

    const wrapped = testEnv.wrap(myFunction);
    const result = await wrapped({ userId: '123' });

    expect(result.status).toBe('success');
  });

  test('handles API failure', async () => {
    mockedAxios.get.mockRejectedValue(new Error('Network error'));

    const wrapped = testEnv.wrap(myFunction);
    await expect(wrapped({ userId: '123' })).rejects.toThrow();
  });
});
```

## Wait for async side effects

`await new Promise(resolve => setTimeout(resolve, ms))`

Allow time for triggers or background operations to complete.

```typescript
function waitFor(ms: number) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

test('waits for trigger side effects', async () => {
  await createDocument();
  await waitFor(1000);

  const result = await checkSideEffect();
  expect(result).toBeDefined();
});
```
