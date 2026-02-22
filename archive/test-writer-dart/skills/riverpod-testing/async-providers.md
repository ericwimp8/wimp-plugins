# Testing Async Providers

Patterns for FutureProvider, StreamProvider, and async completion.

## Wait for FutureProvider to complete

`container.read(provider.future)`

```dart
test('fetches user data correctly', () async {
  final container = ProviderContainer.test(
    overrides: [
      apiClientProvider.overrideWithValue(mockApiClient),
    ],
  );

  await expectLater(
    container.read(userProvider.future),
    completion(isA<User>().having((u) => u.name, 'name', 'John')),
  );
});
```

## Prevent auto-disposing provider from disposing during test

`container.listen(provider, (_, __) {})`

Use `listen()` instead of `read()` for auto-disposing providers to prevent premature disposal:

```dart
test('auto-dispose provider stays alive', () async {
  final container = ProviderContainer.test();

  // Listen keeps the provider alive
  final subscription = container.listen<AsyncValue<User>>(
    userProvider,
    (previous, next) {},
  );

  // subscription.read() works like container.read()
  // but provider won't dispose until subscription is disposed
  final result = await subscription.read().future;
  expect(result.name, 'Expected Name');
});
```

## Test StreamProvider emissions

```dart
final messagesProvider = StreamProvider<List<Message>>((ref) {
  return ref.watch(chatRepositoryProvider).messageStream;
});

test('stream emits messages correctly', () async {
  final mockStream = Stream.fromIterable([
    [Message(id: '1', text: 'Hello')],
    [Message(id: '1', text: 'Hello'), Message(id: '2', text: 'World')],
  ]);

  final container = ProviderContainer.test(
    overrides: [
      chatRepositoryProvider.overrideWith((ref) => MockChatRepository(mockStream)),
    ],
  );

  final subscription = container.listen(messagesProvider.future, (_, __) {});
  final messages = await subscription.read();
  expect(messages.length, 2);
});
```

## Inject loading state directly

`provider.overrideWithValue(const AsyncLoading())`

```dart
test('shows loading indicator', () {
  final container = ProviderContainer.test(
    overrides: [
      dataProvider.overrideWithValue(const AsyncLoading()),
    ],
  );

  expect(container.read(dataProvider), const AsyncLoading<Data>());
});
```

## Inject error state directly

`provider.overrideWithValue(AsyncError(exception, stackTrace))`

```dart
test('handles error state', () {
  final container = ProviderContainer.test(
    overrides: [
      dataProvider.overrideWithValue(
        AsyncError(Exception('Network failure'), StackTrace.current),
      ),
    ],
  );

  expect(container.read(dataProvider).hasError, true);
});
```

## Test cache indicator for offline scenarios

`AsyncData(value, isFromCache: true)`

```dart
test('shows cache indicator when data is from cache', () {
  final container = ProviderContainer.test(
    overrides: [
      dataProvider.overrideWithValue(
        AsyncData(Data(), isFromCache: true),
      ),
    ],
  );

  final value = container.read(dataProvider);
  expect(value.isFromCache, true);
});
```

## Track loading progress

`AsyncLoading` with progress property:

```dart
test('tracks loading progress', () async {
  final progressValues = <double>[];
  final container = ProviderContainer.test();

  container.listen<AsyncValue<Data>>(
    uploadProvider,
    (_, next) {
      if (next is AsyncLoading<Data>) {
        progressValues.add(next.progress ?? 0);
      }
    },
  );

  await container.read(uploadProvider.notifier).upload(file);
  expect(progressValues, [0.0, 0.25, 0.5, 0.75, 1.0]);
});
```
