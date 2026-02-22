# Testing Notifiers

Patterns for Notifier and AsyncNotifier classes, including state transition verification.

## Verify state transitions with Listener mock pattern

`Listener<T>` mock class with `container.listen(..., fireImmediately: true)`

This pattern from the Riverpod test suite enables precise state transition verification:

```dart
import 'package:mocktail/mocktail.dart';

class Listener<T> extends Mock {
  void call(T? previous, T next);
}

void main() {
  setUpAll(() {
    registerFallbackValue(const AsyncLoading<void>());
  });

  test('sign-in transitions through correct states', () async {
    final listener = Listener<AsyncValue<void>>();
    final mockAuth = MockAuthRepository();
    when(() => mockAuth.signIn(any(), any())).thenAnswer((_) async {});

    final container = ProviderContainer.test(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuth),
      ],
    );

    container.listen(
      authControllerProvider,
      listener.call,
      fireImmediately: true,
    );

    // Verify initial state
    verify(() => listener(null, const AsyncData<void>(null)));

    // Trigger sign-in
    await container.read(authControllerProvider.notifier).signIn('test@example.com', 'password');

    // Verify state transitions
    verifyInOrder([
      () => listener(const AsyncData(null), any(that: isA<AsyncLoading>())),
      () => listener(any(that: isA<AsyncLoading>()), const AsyncData<void>(null)),
    ]);
    verifyNoMoreInteractions(listener);
  });
}
```

## Track complete state history

`container.listen()` with list capture:

```dart
test('tracks complete state history', () async {
  final changes = <int>[];
  final container = ProviderContainer.test();

  container.listen<int>(
    counterProvider,
    (previous, next) => changes.add(next),
    fireImmediately: true,
  );

  container.read(counterProvider.notifier).increment();
  container.read(counterProvider.notifier).increment();
  container.read(counterProvider.notifier).decrement();

  expect(changes, [0, 1, 2, 1]);
});
```

## Mock dependencies instead of Notifiers

Riverpod strongly discourages direct Notifier mocking. Mock the dependency:

```dart
// Correct: Mock the dependency
final container = ProviderContainer.test(
  overrides: [
    todoRepositoryProvider.overrideWithValue(MockTodoRepository()),
  ],
);

// Also correct: Use overrideWithBuild for initial state
final container = ProviderContainer.test(
  overrides: [
    todoNotifierProvider.overrideWithBuild((ref) => [Todo(id: '1', title: 'Test')]),
  ],
);
```

## Mock a Notifier directly (when necessary)

Subclass the base class—never use `implements`:

```dart
// Wrong: implements doesn't work
class MyNotifierMock with Mock implements MyNotifier {}

// Correct: Subclass the base
class MyNotifierMock extends Notifier<int> with Mock implements MyNotifier {}

// Usage
final container = ProviderContainer.test(
  overrides: [
    myProvider.overrideWith(MyNotifierMock.new),
  ],
);
```

## Mock code-generated Notifiers

The mock must be in the same file to access the generated base class:

```dart
// In the same file as the @riverpod annotation
class MyNotifierMock extends _$MyNotifier with Mock implements MyNotifier {}
```

## Check provider lifecycle after async operations

`ref.mounted`

```dart
class DataNotifier extends AsyncNotifier<Data> {
  Future<void> refresh() async {
    state = const AsyncLoading();
    final data = await repository.fetch();
    if (!ref.mounted) return; // Provider was disposed during fetch
    state = AsyncData(data);
  }
}
```

Use `ref.mounted` to verify the provider is still active after async operations complete.
