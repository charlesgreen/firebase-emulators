# Firebase Emulators - Quick Reference

Essential commands and copy-paste snippets for instant productivity.

## 🚀 Instant Start

```bash
# Option 1: Docker Compose (Recommended)
curl -sSL https://raw.githubusercontent.com/charlesgreen/firebase-emulators/main/docker-compose.yml | docker-compose -f - up -d

# Option 2: Docker Run
docker run -p 5170-5179:5170-5179 charlesgreen/firebase-emulators:latest

# Access Firebase UI
open http://localhost:5179
```

## 📋 Essential Commands

### Start/Stop

```bash
# Start with seed data
docker run -e SEED_DATA=true -p 5170-5179:5170-5179 charlesgreen/firebase-emulators:latest

# Stop
docker stop firebase-emulators

# Restart
docker restart firebase-emulators
```

### Management

```bash
# Check status
docker ps | grep firebase

# View logs
docker logs firebase-emulators

# Clear data
docker exec firebase-emulators ./scripts/admin-tools.sh clear

# Open shell
docker exec -it firebase-emulators /bin/bash
```

## 🔗 Port Reference

| Service | Port | URL |
|---------|------|-----|
| **UI Dashboard** | **5179** | **http://localhost:5179** |
| Auth | 5171 | http://localhost:5171 |
| Firestore | 5172 | http://localhost:5172 |
| Storage | 5175 | http://localhost:5175 |

## 👤 Test Accounts

```text
admin@example.com / password123
user@example.com / password123  
john.doe@example.com / password123
```

## 📝 Environment Variables

### Essential
```bash
FIREBASE_PROJECT_ID=your-project-id
SEED_DATA=true
```

### Complete List
```bash
FIREBASE_PROJECT_ID=demo-project
ENABLE_AUTH=true
ENABLE_FIRESTORE=true  
ENABLE_HOSTING=true
ENABLE_STORAGE=true
SEED_DATA=false
SEED_AUTH=false
SEED_FIRESTORE=false
```

## 🔧 Integration Snippets

### Docker Compose

```yaml
# docker-compose.yml
services:
  firebase-emulators:
    image: charlesgreen/firebase-emulators:latest
    ports:
      - "5170-5179:5170-5179"
    environment:
      - FIREBASE_PROJECT_ID=my-project
      - SEED_DATA=true
```

### Package.json Scripts

```json
{
  "scripts": {
    "emulators": "docker run -d --name firebase-emulators -p 5170-5179:5170-5179 charlesgreen/firebase-emulators:latest",
    "emulators:stop": "docker stop firebase-emulators && docker rm firebase-emulators",
    "emulators:seed": "docker run -d --name firebase-emulators -p 5170-5179:5170-5179 -e SEED_DATA=true charlesgreen/firebase-emulators:latest"
  }
}
```

### Makefile

```makefile
firebase-start:
	docker run -d --name firebase-emulators -p 5170-5179:5170-5179 -e SEED_DATA=true charlesgreen/firebase-emulators:latest

firebase-stop:
	docker stop firebase-emulators && docker rm firebase-emulators
```

### JavaScript/TypeScript

```javascript
// Connect to emulators in development
if (process.env.NODE_ENV === 'development') {
  connectAuthEmulator(auth, 'http://localhost:5171');
  connectFirestoreEmulator(db, 'localhost', 5172);
  connectStorageEmulator(storage, 'localhost', 5175);
}
```

## 🧪 Testing Setup

### Environment Variables

```bash
# .env.test
FIRESTORE_EMULATOR_HOST=localhost:5172
FIREBASE_AUTH_EMULATOR_HOST=localhost:5171
FIREBASE_STORAGE_EMULATOR_HOST=localhost:5175
FIREBASE_PROJECT_ID=test-project
```

### GitHub Actions

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
```

### Jest Setup

```javascript
// jest.setup.js
process.env.FIRESTORE_EMULATOR_HOST = 'localhost:5172';
process.env.FIREBASE_AUTH_EMULATOR_HOST = 'localhost:5171';
process.env.FIREBASE_STORAGE_EMULATOR_HOST = 'localhost:5175';
```

## 🛠️ Troubleshooting

### Common Issues

| Problem | Solution |
|---------|----------|
| Can't access UI | Check `docker ps` and port mapping |
| Port conflicts | Use `-p 6170-6179:5170-5179` |
| Seed data not loading | Add `SEED_DATA=true` |
| Permission errors | Check volume mount permissions |

### Debug Commands

```bash
# Check container status
docker ps --filter "name=firebase-emulators"

# Check port mappings  
docker port firebase-emulators

# View detailed logs
docker logs firebase-emulators --follow

# Check emulator health
curl -f http://localhost:5179 || echo "UI not ready"
```

## 🔄 Common Workflows

### Development Cycle

```bash
# 1. Start emulators with data
docker run -d --name firebase-emulators -p 5170-5179:5170-5179 -e SEED_DATA=true charlesgreen/firebase-emulators:latest

# 2. Develop your app
npm run dev

# 3. Clear data when needed
docker exec firebase-emulators ./scripts/admin-tools.sh clear

# 4. Stop when done
docker stop firebase-emulators && docker rm firebase-emulators
```

### Testing Cycle

```bash
# 1. Start fresh emulators
docker run -d --name test-emulators -p 5170-5179:5170-5179 charlesgreen/firebase-emulators:latest

# 2. Run tests
export FIRESTORE_EMULATOR_HOST=localhost:5172
npm test

# 3. Cleanup
docker stop test-emulators && docker rm test-emulators
```

## 📖 More Info

- **Full Documentation**: [README.md](README.md)
- **Docker Hub**: https://hub.docker.com/r/charlesgreen/firebase-emulators
- **Examples**: [examples/](examples/)
- **Issues**: https://github.com/charlesgreen/firebase-emulators/issues