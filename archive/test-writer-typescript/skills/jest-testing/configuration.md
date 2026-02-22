# Configuration

Setup and configuration for Jest with TypeScript using ts-jest.

## Install test dependencies

`npm install --save-dev jest ts-jest @types/jest typescript`

Required packages for TypeScript testing with Jest.

## Configure Jest for TypeScript

`jest.config.ts`

```typescript
import type { Config } from 'jest';

const config: Config = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/src'],
  testMatch: ['**/__tests__/**/*.ts', '**/?(*.)+(spec|test).ts'],
  transform: {
    '^.+\\.tsx?$': 'ts-jest',
  },
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx', 'json', 'node'],
  collectCoverage: true,
  coverageDirectory: 'coverage',
  coveragePathIgnorePatterns: ['/node_modules/'],
  clearMocks: true,
  restoreMocks: true,
};

export default config;
```

## Configure TypeScript for tests

`tsconfig.json`

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "esModuleInterop": true,
    "strict": true,
    "skipLibCheck": true,
    "resolveJsonModule": true
  },
  "include": ["src/**/*", "test/**/*"]
}
```

## Add test scripts to package.json

`scripts`

```json
{
  "scripts": {
    "test": "jest",
    "test:watch": "jest --watchAll",
    "test:coverage": "jest --coverage"
  }
}
```

## Run tests

`npm test`

Executes all tests matching the configured patterns.

## Run tests in watch mode

`npm run test:watch`

Re-runs tests when files change.

## Generate coverage report

`npm run test:coverage`

Outputs coverage to the configured `coverageDirectory`.
