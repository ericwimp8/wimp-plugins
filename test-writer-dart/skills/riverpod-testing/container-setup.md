# Container Setup

Core testing architecture for Riverpod 3.0 unit tests.

## Create an isolated test container

`ProviderContainer.test()`

```dart
void main() {
  test('Counter increments correctly', () {
    final container = ProviderContainer.test();

    expect(container.read(counterProvider), 0);
    container.read(counterProvider.notifier).increment();
    expect(container.read(counterProvider), 1);
    // Container auto-disposes after test ends
  });
}
```

The `ProviderContainer.test()` constructor integrates with Dart's test framework to automatically call `dispose()` via `addTearDown`. Never share containers between tests—each test creates its own container with independent state.

## Add overrides to a test container

`ProviderContainer.test(overrides: [...])`

```dart
final container = ProviderContainer.test(
  overrides: [
    repositoryProvider.overrideWith((ref) => MockRepository()),
  ],
);
```

Accepts the same parameters as the regular constructor: `overrides` and `observers`.

## Add observers for debugging

`ProviderContainer.test(observers: [...])`

```dart
class TestObserver extends ProviderObserver {
  final updates = <String>[];

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    updates.add('${context.provider.name}: $previousValue -> $newValue');
  }
}

test('observer captures all updates', () {
  final observer = TestObserver();
  final container = ProviderContainer.test(observers: [observer]);

  container.read(counterProvider.notifier).increment();

  expect(observer.updates, contains('counterProvider: 0 -> 1'));
});
```

## Flush pending provider rebuilds

`container.pump()`

```dart
test('derived provider updates after source change', () async {
  final container = ProviderContainer.test();

  container.read(counterProvider.notifier).increment();
  await container.pump(); // Flush pending rebuilds

  expect(container.read(isCounterOddProvider), true);
});
```

Providers rebuild asynchronously. When testing providers that depend on other providers, flush pending updates with `pump()`.

## Migrate from 2.x createContainer

Replace `createContainer` with `ProviderContainer.test`:

```dart
// Before (2.x community pattern)
final container = createContainer(
  overrides: [myProvider.overrideWith((ref) => 'test')],
);

// After (3.0 official API)
final container = ProviderContainer.test(
  overrides: [myProvider.overrideWith((ref) => 'test')],
);
```
