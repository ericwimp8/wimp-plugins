# Migration to Riverpod 3.0

Breaking changes and new features affecting tests.

## Handle ProviderException wrapping

All provider failures are now wrapped in `ProviderException`:

```dart
// Riverpod 2.x
try {
  await container.read(failingProvider.future);
} on NetworkException catch (e) {
  // Handle directly
}

// Riverpod 3.0
try {
  await container.read(failingProvider.future);
} on ProviderException catch (e) {
  if (e.exception is NetworkException) {
    // Handle wrapped exception
  }
}
```

## Disable automatic retry in tests

Providers now automatically retry failures with exponential backoff (200ms doubling to 6.4s max). This causes `pumpAndSettle()` to hang or throw multiple exceptions.

Disable globally for tests:

```dart
final container = ProviderContainer.test(
  retry: (retryCount, error) => null,
);
```

Disable per-provider:

```dart
final myProvider = FutureProvider<Data>(
  (ref) async => fetchData(),
  retry: (retryCount, error) => null,
);
```

## Update deprecated type names

| Riverpod 2.x | Riverpod 3.0 |
|--------------|--------------|
| `AutoDisposeNotifier<T>` | `Notifier<T>` |
| `AutoDisposeAsyncNotifier<T>` | `AsyncNotifier<T>` |
| `FamilyNotifier<State, Arg>` | `Notifier<State>` with constructor parameter |
| `ExampleRef ref` | `Ref ref` |
| `StateProvider` | `import 'package:riverpod/legacy.dart'` |

## Handle equality-based state updates

All providers now use `==` for state comparison. StreamProvider users are most affected—emitting the same list instance won't trigger updates.

Override to always notify (restores 2.x behavior):

```dart
class TodoListNotifier extends StreamNotifier<List<Todo>> {
  @override
  Stream<List<Todo>> build() => repository.todoStream;

  @override
  bool updateShouldNotify(
    AsyncValue<List<Todo>> previous,
    AsyncValue<List<Todo>> next,
  ) => true;
}
```

## Replace createContainer

Global search-replace:

```dart
// Before
final container = createContainer(...);

// After
final container = ProviderContainer.test(...);
```

## Use tester.container() in widget tests

New in 3.0:

```dart
// Before (no direct access)
// Had to track container separately

// After
final container = tester.container();
container.read(myProvider.notifier).doSomething();
```
