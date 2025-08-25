# Firebase Emulators

Production-ready Docker container for Firebase emulators with zero-config setup. Perfect for development, testing, and CI/CD pipelines.

## Ultra-Quick Start

```bash
# Option 1: Docker Compose (Recommended)
curl -sSL https://raw.githubusercontent.com/charlesgreen/firebase-emulators/main/docker-compose.yml | docker-compose -f - up -d

# Option 2: Docker Run
docker run -p 5170-5179:5170-5179 charlesgreen/firebase-emulators:latest
```

**That's it!** Firebase UI available at http://localhost:5179

## Integration Examples

Add to your project in seconds:

```bash
# Turborepo
npm install --save-dev @charlesgreen/firebase-emulators

# Docker Compose
curl -sSL https://raw.githubusercontent.com/charlesgreen/firebase-emulators/main/examples/docker-compose-integration/docker-compose.yml >> docker-compose.yml

# Makefile
curl -sSL https://raw.githubusercontent.com/charlesgreen/firebase-emulators/main/examples/makefile-integration/Makefile >> Makefile
```

## Port Reference

| Service | Port | URL |
|---------|------|-----|
| **UI Dashboard** | **5179** | **http://localhost:5179** |
| Auth | 5171 | http://localhost:5171 |
| Firestore | 5172 | http://localhost:5172 |
| Storage | 5175 | http://localhost:5175 |
| Hosting | 5174 | http://localhost:5174 |
| Hub | 5170 | http://localhost:5170 |

## Configuration

### Essential Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `FIREBASE_PROJECT_ID` | `demo-project` | Your Firebase project ID |
| `SEED_DATA` | `false` | Load sample data for testing |

### All Environment Variables

<details>
<summary>Click to expand full configuration options</summary>

| Variable | Default | Description |
|----------|---------|-------------|
| `FIREBASE_PROJECT_ID` | `demo-project` | Firebase project ID |
| `ENABLE_AUTH` | `true` | Enable Auth emulator |
| `ENABLE_FIRESTORE` | `true` | Enable Firestore emulator |
| `ENABLE_HOSTING` | `true` | Enable Hosting emulator |
| `ENABLE_STORAGE` | `true` | Enable Storage emulator |
| `SEED_DATA` | `false` | Enable seed data import |
| `SEED_AUTH` | `false` | Import auth seed data |
| `SEED_FIRESTORE` | `false` | Import Firestore seed data |

</details>

## Common Use Cases

### Development with Seed Data

```bash
# Start with sample data for immediate testing
docker run -e SEED_DATA=true -e FIREBASE_PROJECT_ID=my-app -p 5170-5179:5170-5179 charlesgreen/firebase-emulators:latest
```

**Included test accounts:**
- `admin@example.com` / `password123`
- `user@example.com` / `password123`

### CI/CD Pipeline

```yaml
# .github/workflows/test.yml
services:
  firebase:
    image: charlesgreen/firebase-emulators:latest
    ports:
      - 5170-5179:5170-5179
    env:
      FIREBASE_PROJECT_ID: test-project
```

### Custom Project Configuration

```bash
# Mount your firebase.json and security rules
docker run -v ./firebase.json:/app/config/firebase.json:ro \
  -v ./firestore.rules:/app/config/firestore.rules:ro \
  -p 5170-5179:5170-5179 charlesgreen/firebase-emulators:latest
```

## Management Commands

```bash
# Check status
docker exec firebase-emulators ./scripts/admin-tools.sh status

# Clear all data
docker exec firebase-emulators ./scripts/admin-tools.sh clear

# Create backup
docker exec firebase-emulators ./scripts/admin-tools.sh backup my-backup
```

## Docker Hub Usage

```bash
# Latest stable version
docker pull charlesgreen/firebase-emulators:latest

# Specific version
docker pull charlesgreen/firebase-emulators:v1.0.0

# Development version
docker pull charlesgreen/firebase-emulators:dev
```

## Troubleshooting

### Quick Fixes

**Can't access emulators?**
```bash
# Check if container is running
docker ps | grep firebase

# Check ports are mapped correctly
docker port firebase-emulators
```

**Need debug output?**
```bash
docker logs firebase-emulators
```

**Performance issues?**
```bash
# Monitor resource usage
docker stats firebase-emulators
```

### Common Issues

| Problem | Solution |
|---------|----------|
| Port conflicts | Change port mapping: `-p 6170-6179:5170-5179` |
| Seed data not loading | Add `SEED_DATA=true` environment variable |
| Permission errors | Ensure volume mounts have correct permissions |

## Features

- ✅ **Zero-config setup** - Works out of the box
- ✅ **Multi-platform** - linux/amd64, linux/arm64
- ✅ **Security hardened** - Non-root user, health checks
- ✅ **Seed data included** - Ready-to-use test accounts
- ✅ **CI/CD ready** - GitHub Actions workflow included
- ✅ **Production ready** - Resource limits, monitoring

## Links

- **Docker Hub**: [charlesgreen/firebase-emulators](https://hub.docker.com/r/charlesgreen/firebase-emulators)
- **Issues**: [GitHub Issues](https://github.com/charlesgreen/firebase-emulators/issues)
- **Firebase Docs**: [Emulator Suite](https://firebase.google.com/docs/emulator-suite)

## Quick Reference

See [QUICKSTART.md](QUICKSTART.md) for essential commands and copy-paste snippets.