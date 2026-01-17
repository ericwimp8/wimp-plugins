# Provider Overrides

Three override mechanisms for different testing scenarios.

## Replace entire provider initialization

`provider.overrideWith((ref) => value)`

```dart
final container = ProviderContainer.test(
  overrides: [
    repositoryProvider.overrideWith((ref) => MockRepository()),
    userProvider.overrideWith((ref) {
      return User(id: 'test-123', name: 'Test User');
    }),
  ],
);
```

## Override specific family instance

`provider(arg).overrideWith((ref) => value)`

```dart
final container = ProviderContainer.test(
  overrides: [
    userProvider('user-123').overrideWith((ref) => mockUser),
  ],
);
```

## Override all family instances

`provider.overrideWith((ref, arg) => value)`

```dart
final container = ProviderContainer.test(
  overrides: [
    userProvider.overrideWith((ref, userId) => User(id: userId, name: 'Mock $userId')),
  ],
);
```

## Override AsyncNotifier family providers

`asyncNotifierProvider(arg).overrideWith((ref) async => value)`

AsyncNotifierProvider does not support `overrideWithValue()`. Use `overrideWith` with an async function:

```dart
final container = ProviderContainer.test(
  overrides: [
    databaseServiceProvider(user).overrideWith((ref) async => mockDatabaseService),
    localDatabaseProvider(user).overrideWith((ref) async => mockLocalDatabase),
  ],
);

final service = await container.read(databaseServiceProvider(user).future);
```

For error states, throw from the async function:

```dart
final container = ProviderContainer.test(
  overrides: [
    databaseServiceProvider(user).overrideWith(
      (ref) async => throw DatabaseException('Connection failed'),
    ),
  ],
);
```

## Inject specific AsyncValue states

`asyncProvider.overrideWithValue(AsyncValue)`

For FutureProvider and StreamProvider only (not AsyncNotifierProvider):

```dart
test('test loading state', () {
  final container = ProviderContainer.test(
    overrides: [
      myFutureProvider.overrideWithValue(const AsyncLoading()),
    ],
  );
  expect(container.read(myFutureProvider), const AsyncLoading<int>());
});

test('test error state', () {
  final container = ProviderContainer.test(
    overrides: [
      myFutureProvider.overrideWithValue(
        AsyncError(Exception('Network failure'), StackTrace.current),
      ),
    ],
  );
  expect(container.read(myFutureProvider).hasError, true);
});
```

## Set Notifier initial state while preserving methods

`notifierProvider.overrideWithBuild((ref) => initialState)`

New in 3.0. Mocks only the `build()` method while preserving all other Notifier functionality:

```dart
class CartNotifier extends Notifier<List<Item>> {
  @override
  List<Item> build() => [];

  void addItem(Item item) => state = [...state, item];
  void clear() => state = [];
}

final cartProvider = NotifierProvider<CartNotifier, List<Item>>(CartNotifier.new);

test('addItem works with pre-populated cart', () {
  final container = ProviderContainer.test(
    overrides: [
      cartProvider.overrideWithBuild((ref) {
        // Start with existing items, but addItem/clear work normally
        return [Item(id: '1'), Item(id: '2')];
      }),
    ],
  );

  expect(container.read(cartProvider).length, 2);
  container.read(cartProvider.notifier).addItem(Item(id: '3'));
  expect(container.read(cartProvider).length, 3);
});
```

## Summary: Which override to use

| Scenario | Method |
|----------|--------|
| Replace provider completely | `overrideWith` |
| Override one family instance | `provider(arg).overrideWith` |
| Override all family instances | `provider.overrideWith((ref, arg) => ...)` |
| Override AsyncNotifier family provider | `provider(arg).overrideWith((ref) async => ...)` |
| Inject async state (FutureProvider/StreamProvider) | `overrideWithValue` |
| Set Notifier initial state only | `overrideWithBuild` |
