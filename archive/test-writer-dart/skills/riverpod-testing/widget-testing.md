# Widget Testing

Testing widgets with ProviderScope and accessing providers from widget tests.

## Basic widget test with overrides

`ProviderScope(overrides: [...], child: widget)`

```dart
testWidgets('displays counter value', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        counterProvider.overrideWith((ref) => 42),
      ],
      child: const MaterialApp(home: CounterPage()),
    ),
  );

  expect(find.text('42'), findsOneWidget);
});
```

## Access container from widget test

`tester.container()`

New in 3.0:

```dart
testWidgets('can interact with providers after widget build', (tester) async {
  await tester.pumpWidget(
    const ProviderScope(child: MaterialApp(home: CounterPage())),
  );

  final container = tester.container();

  // Read and verify state
  expect(container.read(counterProvider), 0);

  // Trigger notifier method
  container.read(counterProvider.notifier).increment();
  await tester.pump();

  expect(find.text('1'), findsOneWidget);
});
```

## Pre-load async data before widget builds

`UncontrolledProviderScope(container: container, child: widget)`

```dart
testWidgets('widget with pre-loaded data', (tester) async {
  final container = ProviderContainer.test();

  // Pre-load async data
  await container.read(userProvider.future);
  await container.read(settingsProvider.future);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: HomePage()),
    ),
  );

  // Widget immediately has access to loaded data
  expect(find.text('Welcome, John'), findsOneWidget);
});
```

## Reusable widget test helper

Create an extension for simplified test setup:

```dart
extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget widget, {
    List<Override> overrides = const [],
  }) async {
    return pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          home: Scaffold(body: widget),
        ),
      ),
    );
  }
}

// Usage
testWidgets('simplified setup', (tester) async {
  await tester.pumpApp(
    const MyWidget(),
    overrides: [myProvider.overrideWith((ref) => 'test')],
  );
});
```

## Summary: Widget test patterns

| Scenario | Approach |
|----------|----------|
| Simple override | `ProviderScope(overrides: [...])` |
| Access container in test | `tester.container()` |
| Pre-load async providers | `UncontrolledProviderScope` with pre-awaited container |
| Reusable setup | Extension method on `WidgetTester` |
