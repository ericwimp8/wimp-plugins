# Core Concepts

Mocktail provides null-safe mocking without code generation, working with `package:test` and `flutter_test`.

## Create a mock for stubbing and verification

`class MockClass extends Mock implements YourClass {}`

Allows stubbing method return values with `when()` and verification with `verify()`. Unstubbed methods return `null` by default.

```dart
class MockUserRepository extends Mock implements UserRepository {}

final mock = MockUserRepository();
when(() => mock.getUser('123')).thenAnswer((_) async => user);
verify(() => mock.getUser('123')).called(1);
```

## Create a fake for partial implementation

`class FakeClass extends Fake implements YourClass {}`

Provides partial real implementations. Override specific methods with actual logic. Unoverridden methods throw `UnimplementedError`. Cannot use `when()`/`verify()` with Fakes.

```dart
class FakeUserRepository extends Fake implements UserRepository {
  @override
  Future<User> getUser(String id) async {
    return User(id: id, name: 'Test User');
  }
}
```

## Choose between Mock and Fake

| Use Mock When | Use Fake When |
|---------------|---------------|
| Testing interactions (method called X times) | Need consistent, predictable data |
| Different return values per test | Simulating complex behavior |
| Need to verify arguments passed | Partial implementations suffice |
| Testing error scenarios | Performance-sensitive tests |

## Mock a callback or function

`class MockCallback extends Mock { void call(...); }`

For mocking top-level functions or callbacks, create a mock class with a `call` method matching the function signature.

```dart
class MockCallback extends Mock {
  void call(String value);
}

class MockAsyncCallback extends Mock {
  Future<bool> call(Uri url, {LaunchMode? mode});
}

final mockCallback = MockCallback();
when(() => mockCallback('test')).thenReturn(null);
```

## Set up test lifecycle with mocks

`setUp()` / `tearDown()` / `setUpAll()`

Structure tests with proper lifecycle management to prevent test pollution.

```dart
void main() {
  late MockApiClient mockClient;
  late UserRepository repository;

  setUpAll(() {
    registerFallbackValue(FakeUser());
    registerFallbackValue(Uri());
  });

  setUp(() {
    mockClient = MockApiClient();
    repository = UserRepository(client: mockClient);
  });

  tearDown(() => reset(mockClient));

  group('getUser', () {
    test('returns user on success', () async {
      // Arrange
      when(() => mockClient.get(any())).thenAnswer(
        (_) async => Response(body: '{"id": "1", "name": "Test"}'),
      );

      // Act
      final user = await repository.getUser('1');

      // Assert
      expect(user.name, 'Test');
      verify(() => mockClient.get(any())).called(1);
    });
  });
}
```

## Reset mock state between tests

`reset(mock)` / `clearInteractions(mock)` / `resetMocktailState()`

- `reset(mock)` - Clears stubs AND interactions
- `clearInteractions(mock)` - Clears only interactions, keeps stubs
- `resetMocktailState()` - Global reset of all Mocktail state

```dart
tearDown(() {
  reset(mockRepo);
});

// Or for global reset
tearDown(resetMocktailState);
```
