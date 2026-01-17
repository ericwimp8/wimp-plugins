# Test Data Patterns

Structured patterns for creating readable, type-safe test data. Builder pattern for flexibility, Object Mother for common scenarios.

## Use Builder pattern for flexible test data

`new UserBuilder().withRole('admin').build()`

Method chaining with sensible defaults:

```typescript
interface User {
  id: number;
  firstName: string;
  lastName: string;
  email: string;
  role: 'admin' | 'user' | 'guest';
  isActive: boolean;
}

class UserBuilder {
  private user: User = {
    id: 1,
    firstName: 'John',
    lastName: 'Doe',
    email: 'john@example.com',
    role: 'user',
    isActive: true
  };

  withId(id: number): this { this.user.id = id; return this; }
  withName(firstName: string, lastName: string): this {
    this.user.firstName = firstName;
    this.user.lastName = lastName;
    return this;
  }
  withRole(role: User['role']): this { this.user.role = role; return this; }
  asAdmin(): this { return this.withRole('admin'); }
  asInactive(): this { this.user.isActive = false; return this; }
  build(): User { return { ...this.user }; }

  // Static factory methods for common scenarios
  static anAdmin(): UserBuilder { return new UserBuilder().asAdmin(); }
  static aGuest(): UserBuilder { return new UserBuilder().withRole('guest').asInactive(); }
}

// Usage
const admin = UserBuilder.anAdmin().withName('Admin', 'User').build();
```

## Use Object Mother for predefined scenarios

`UserMother.premiumUser()`

Static factory methods for common test data:

```typescript
class UserMother {
  static default(): User {
    return { id: 1, name: 'Default User', email: 'default@example.com', subscription: 'free' };
  }

  static premiumUser(): User {
    return { ...UserMother.default(), subscription: 'premium', name: 'Premium User' };
  }

  static multiple(count: number): User[] {
    return Array.from({ length: count }, (_, i) => ({
      ...UserMother.default(),
      id: i + 1,
      name: `User ${i + 1}`,
      email: `user${i + 1}@example.com`
    }));
  }
}
```

## Create typed test context setup

`setupTestDependencies(): TestDependencies`

Centralize dependency creation:

```typescript
interface TestDependencies {
  userService: UserService;
  mockRepository: jest.Mocked<UserRepository>;
}

function setupTestDependencies(): TestDependencies {
  const mockRepository: jest.Mocked<UserRepository> = {
    findById: jest.fn(),
    save: jest.fn(),
    delete: jest.fn()
  };

  const userService = new UserService(mockRepository);
  return { userService, mockRepository };
}

describe('UserService', () => {
  let deps: TestDependencies;

  beforeEach(() => { deps = setupTestDependencies(); });

  test('finds user by id', async () => {
    const expectedUser = UserBuilder.default().build();
    deps.mockRepository.findById.mockResolvedValue(expectedUser);

    const result = await deps.userService.getUser(1);

    expect(result).toEqual(expectedUser);
    expect(deps.mockRepository.findById).toHaveBeenCalledWith(1);
  });
});
```

## Combine Builder with Object Mother

`UserMother.anAdmin().withCustomEmail('admin@test.com').build()`

Best of both patterns:

```typescript
class UserMother {
  static default(): UserBuilder {
    return new UserBuilder();
  }

  static anAdmin(): UserBuilder {
    return new UserBuilder().asAdmin();
  }

  static aGuestUser(): UserBuilder {
    return new UserBuilder().withRole('guest').asInactive();
  }
}

// Fluent customization of predefined scenarios
const customAdmin = UserMother.anAdmin()
  .withName('Custom', 'Admin')
  .withEmail('custom@admin.com')
  .build();
```

## Create factory functions with overrides

`createMockUser(overrides?: Partial<User>): User`

Simple approach for less complex objects:

```typescript
function createMockUser(overrides: Partial<User> = {}): User {
  return {
    id: '1',
    firstName: 'John',
    lastName: 'Doe',
    email: 'john@example.com',
    profile: { avatar: '', bio: '' },
    ...overrides
  };
}

// Test only specifies what matters
const user = createMockUser({ email: 'custom@example.com' });
```

## Generate unique test data

`faker.string.uuid()` or sequential IDs

Avoid collisions in parallel tests:

```typescript
let idCounter = 0;

class UserBuilder {
  private user: User = {
    id: ++idCounter,  // Unique per instance
    // ...
  };
}

// Or with faker
import { faker } from '@faker-js/faker';

function createRandomUser(): User {
  return {
    id: faker.string.uuid(),
    firstName: faker.person.firstName(),
    lastName: faker.person.lastName(),
    email: faker.internet.email()
  };
}
```
