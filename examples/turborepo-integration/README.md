# Firebase Emulators + Turborepo Integration

This example shows how to integrate Firebase Emulators into your Turborepo project for seamless development and testing.

## Quick Setup

1. **Copy files to your Turborepo project:**
   ```bash
   # Copy the Docker Compose config
   cp docker-compose.firebase.yml /path/to/your/turborepo/

   # Add scripts to your package.json (see package.json example)
   ```

2. **Add environment variables:**
   ```bash
   # .env.local
   FIREBASE_PROJECT_ID=your-project-id
   FIRESTORE_EMULATOR_HOST=localhost:5172
   FIREBASE_AUTH_EMULATOR_HOST=localhost:5171
   FIREBASE_STORAGE_EMULATOR_HOST=localhost:5175
   ```

3. **Update your turbo.json:**
   ```json
   {
     "pipeline": {
       "test:integration": {
         "dependsOn": ["^build"],
         "env": [
           "FIRESTORE_EMULATOR_HOST",
           "FIREBASE_AUTH_EMULATOR_HOST",
           "FIREBASE_STORAGE_EMULATOR_HOST",
           "FIREBASE_PROJECT_ID"
         ]
       }
     }
   }
   ```

## Usage

```bash
# Start emulators
npm run emulators

# Start with seed data for testing
npm run emulators:seed

# Run tests with emulators
npm run test:integration

# Stop emulators
npm run emulators:stop
```

## Integration with Turbo Tasks

The emulators integrate seamlessly with Turbo's task pipeline:

- **Development**: `turbo run dev` can depend on `emulators:start`
- **Testing**: `test:e2e` automatically starts emulators
- **CI/CD**: Parallel testing with emulator isolation

## App-level Integration

In your individual apps (Next.js, etc.):

```javascript
// apps/web/lib/firebase.ts
const firebaseConfig = {
  projectId: process.env.FIREBASE_PROJECT_ID,
  // ... other config
};

// Connect to emulators in development
if (process.env.NODE_ENV === 'development') {
  connectAuthEmulator(auth, 'http://localhost:5171');
  connectFirestoreEmulator(db, 'localhost', 5172);
  connectStorageEmulator(storage, 'localhost', 5175);
}
```

## CI/CD Integration

```yaml
# .github/workflows/test.yml
services:
  firebase:
    image: charlesgreen/firebase-emulators:latest
    ports:
      - 5170-5179:5170-5179
    env:
      FIREBASE_PROJECT_ID: ci-project
      SEED_DATA: true

steps:
  - name: Test with emulators
    run: turbo run test:integration --parallel
    env:
      FIRESTORE_EMULATOR_HOST: localhost:5172
      FIREBASE_AUTH_EMULATOR_HOST: localhost:5171
```