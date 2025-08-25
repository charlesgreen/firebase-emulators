# Docker Compose Integration Example

This example demonstrates how to add Firebase Emulators to your existing Docker Compose setup.

## Integration Patterns

### Pattern 1: Service Dependencies

Your app services wait for emulators to be healthy before starting:

```yaml
services:
  web:
    depends_on:
      firebase-emulators:
        condition: service_healthy
```

### Pattern 2: Environment Variables

Connect your services to emulators using environment variables:

```yaml
environment:
  - FIRESTORE_EMULATOR_HOST=firebase-emulators:5172
  - FIREBASE_AUTH_EMULATOR_HOST=firebase-emulators:5171
  - FIREBASE_STORAGE_EMULATOR_HOST=firebase-emulators:5175
```

### Pattern 3: Network Communication

Use Docker networks for internal service communication:

```yaml
networks:
  - app-network
```

## Quick Setup

1. **Copy the example to your project:**

```bash
curl -sSL https://raw.githubusercontent.com/charlesgreen/firebase-emulators/main/examples/docker-compose-integration/docker-compose.yml > docker-compose.firebase.yml
```

1. **Merge with your existing docker-compose.yml:**

```bash
# Option A: Use multiple compose files
docker-compose -f docker-compose.yml -f docker-compose.firebase.yml up -d

# Option B: Copy the firebase-emulators service to your main file
```

1. **Update your app configuration:**

```javascript
// In your app code
if (process.env.NODE_ENV === 'development') {
  connectFirestoreEmulator(db, process.env.FIRESTORE_EMULATOR_HOST || 'localhost', 5172);
}
```

## Development Commands

```bash
# Start everything with emulators
docker-compose up -d

# Start with seed data
SEED_DATA=true SEED_AUTH=true SEED_FIRESTORE=true docker-compose up -d

# View Firebase UI
open http://localhost:5179

# Check emulator status
docker-compose exec firebase-emulators ./scripts/admin-tools.sh status
```

## Production Considerations

- Remove UI port exposure in production
- Disable seed data in production
- Use environment-specific compose files
- Consider resource limits and monitoring

## Environment Files

Create environment-specific configs:

```bash
# .env.development
SEED_DATA=true
SEED_AUTH=true
SEED_FIRESTORE=true

# .env.production
SEED_DATA=false
NODE_ENV=production
```

## Testing Integration

```bash
# Run tests against emulators
docker-compose exec web npm test

# Integration test with fresh data
docker-compose exec firebase-emulators ./scripts/admin-tools.sh clear
docker-compose exec web npm run test:integration
```
