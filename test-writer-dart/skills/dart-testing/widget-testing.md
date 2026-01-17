# Widget Testing

Flutter widget testing patterns with mocks and Riverpod.

## Test a widget with mocked dependencies

`testWidgets()` + `pumpWidget()`

Inject mocks through constructor or provider and verify widget behavior.

```dart
class MockUserService extends Mock implements UserService {}

void main() {
  late MockUserService mockService;

  setUp(() {
    mockService = MockUserService();
  });

  testWidgets('displays user name', (tester) async {
    when(() => mockService.getCurrentUser()).thenReturn(
      User(name: 'John Doe'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: UserProfile(service: mockService),
      ),
    );

    expect(find.text('John Doe'), findsOneWidget);
    verify(() => mockService.getCurrentUser()).called(1);
  });
}
```

## Test widget with Provider

`Provider<Type>.value(value: mock, child: ...)`

Wrap widget with Provider containing the mock.

```dart
testWidgets('widget with provider', (tester) async {
  final mockRepo = MockRepository();
  when(() => mockRepo.getData()).thenAnswer((_) async => testData);

  await tester.pumpWidget(
    MaterialApp(
      home: Provider<Repository>.value(
        value: mockRepo,
        child: const MyWidget(),
      ),
    ),
  );

  await tester.pumpAndSettle();
  expect(find.text('Data loaded'), findsOneWidget);
});
```

## Test widget with Riverpod provider override

`ProviderScope(overrides: [...], child: ...)`

Override providers with mock implementations.

```dart
testWidgets('riverpod provider override', (tester) async {
  final mockService = MockDataService();
  when(() => mockService.fetchItems()).thenAnswer((_) async => []);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dataServiceProvider.overrideWithValue(mockService),
      ],
      child: const MaterialApp(home: ItemList()),
    ),
  );

  await tester.pumpAndSettle();
  verify(() => mockService.fetchItems()).called(1);
});
```

## Advance frames or wait for animations

`pump()` / `pumpAndSettle()`

Control frame advancement in tests.

```dart
testWidgets('async widget', (tester) async {
  // pump() - advance by one frame
  await tester.pump();

  // pump(duration) - advance by specific duration
  await tester.pump(const Duration(milliseconds: 100));

  // pumpAndSettle() - pump until no more frames scheduled
  await tester.pumpAndSettle();

  // pumpAndSettle with timeout
  await tester.pumpAndSettle(const Duration(seconds: 5));
});
```

## Find widgets by various selectors

`find.text()` / `find.byType()` / `find.byKey()` / `find.byIcon()`

Locate widgets for assertions.

```dart
// By text
expect(find.text('Hello'), findsOneWidget);

// By type
expect(find.byType(ElevatedButton), findsOneWidget);

// By key
expect(find.byKey(const Key('submit-btn')), findsOneWidget);

// By icon
expect(find.byIcon(Icons.add), findsOneWidget);
```

## Find widgets with complex selectors

`find.descendant()` / `find.byWidgetPredicate()`

Use descendant finders or custom predicates for complex queries.

```dart
// Descendant finder
expect(
  find.descendant(
    of: find.byType(Card),
    matching: find.text('Title'),
  ),
  findsOneWidget,
);

// Custom predicate
expect(
  find.byWidgetPredicate(
    (widget) => widget is Text && widget.data?.contains('Error') == true,
  ),
  findsOneWidget,
);
```

## Mock network images in tests

`mockNetworkImages()` from mocktail_image_network

Wrap test in mockNetworkImages to avoid network calls.

```dart
import 'package:mocktail_image_network/mocktail_image_network.dart';

testWidgets('widget with network image', (tester) async {
  await mockNetworkImages(() async {
    await tester.pumpWidget(
      MaterialApp(
        home: Image.network('https://example.com/image.png'),
      ),
    );
  });

  expect(find.byType(Image), findsOneWidget);
});
```

## Fake Flutter classes with DiagnosticableMixin

`mixin DiagnosticableToStringMixin`

Required when faking Flutter classes with custom `toString`.

```dart
mixin DiagnosticableToStringMixin on Object {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return super.toString();
  }
}

class FakeThemeData extends Fake
    with DiagnosticableToStringMixin
    implements ThemeData {}

class FakeBuildContext extends Fake implements BuildContext {}
```

## Test Bloc/Cubit with blocTest

`blocTest<Cubit, State>(...)`

Use bloc_test for declarative state emission testing.

```dart
import 'package:bloc_test/bloc_test.dart';

blocTest<UserCubit, UserState>(
  'emits [Loading, Loaded] when fetchUser succeeds',
  setUp: () {
    when(() => mockRepo.getUser(any())).thenAnswer(
      (_) async => User(id: '1', name: 'Test'),
    );
  },
  build: () => cubit,
  act: (cubit) => cubit.fetchUser('1'),
  expect: () => [
    const UserLoading(),
    isA<UserLoaded>().having((s) => s.user.name, 'name', 'Test'),
  ],
  verify: (_) {
    verify(() => mockRepo.getUser('1')).called(1);
  },
);
```

## Mock Cubit/Bloc for widget tests

`MockCubit<State>` / `whenListen()`

Create mock Cubits and control their state streams.

```dart
import 'package:bloc_test/bloc_test.dart';

class MockCounterCubit extends MockCubit<int> implements CounterCubit {}

testWidgets('widget reacts to cubit state', (tester) async {
  final mockCubit = MockCounterCubit();

  when(() => mockCubit.state).thenReturn(0);

  whenListen(
    mockCubit,
    Stream.fromIterable([0, 1, 2]),
    initialState: 0,
  );

  await tester.pumpWidget(
    BlocProvider<CounterCubit>.value(
      value: mockCubit,
      child: const CounterWidget(),
    ),
  );

  expect(find.text('0'), findsOneWidget);
});
```
