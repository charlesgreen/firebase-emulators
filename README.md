# Firebase Emulators

Production-ready Docker container for Firebase emulators with zero-config setup. Built with Turborepo for efficient development and CI/CD pipelines.

## Ultra-Quick Start

```bash
# Docker (Recommended)
docker run -p 5170-5179:5170-5179 charlesgreen/firebase-emulators:latest

# Docker Compose
curl -sSL https://raw.githubusercontent.com/charlesgreen/firebase-emulators/main/docker-compose.yml | docker-compose -f - up -d
```

**Firebase UI**: http://localhost:5179

## Development

```bash
# Turborepo commands
npm run build    # Build all packages
npm run test     # Test all packages  
npm run lint     # Lint all packages
npm run clean    # Clean build artifacts

# Docker commands
npm run start    # Start emulators
npm run stop     # Stop emulators
npm run logs     # View logs
```

## Integration

### Turborepo Projects

```json
{
  "scripts": {
    "emulators": "docker run -d -p 5170-5179:5170-5179 charlesgreen/firebase-emulators:latest",
    "test:integration": "npm run emulators && vitest run && docker stop firebase"
  }
}
```

### Docker Compose

```yaml
services:
  firebase:
    image: charlesgreen/firebase-emulators:latest
    ports: ["5170-5179:5170-5179"]
    environment:
      - SEED_DATA=true
```

### GitHub Actions

```yaml
services:
  firebase:
    image: charlesgreen/firebase-emulators:latest
    ports: [5170-5179:5170-5179]
```

## Port Reference

| Service      | Port | URL                     |
| ------------ | ---- | ----------------------- |
| UI Dashboard | 5179 | `http://localhost:5179` |
| Auth         | 5171 | `http://localhost:5171` |
| Firestore    | 5172 | `http://localhost:5172` |
| Storage      | 5175 | `http://localhost:5175` |
| Hosting      | 5174 | `http://localhost:5174` |
| Hub          | 5170 | `http://localhost:5170` |

## Configuration

| Variable              | Default        | Description                  |
| --------------------- | -------------- | ---------------------------- |
| `FIREBASE_PROJECT_ID` | `demo-project` | Your Firebase project ID     |
| `SEED_DATA`           | `false`        | Load sample data for testing |
| `SEED_AUTH`           | `false`        | Import test accounts         |
| `SEED_FIRESTORE`      | `false`        | Import Firestore test data   |

**Test accounts** (when `SEED_AUTH=true`):
- `admin@example.com` / `password123`
- `user@example.com` / `password123`

## Repository Structure

```
firebase-emulators/
├── packages/
│   ├── emulator/        # Core Docker package
│   ├── config/          # Configuration validation
│   ├── example-go-api/  # Go integration example
│   └── example-react-app/ # React integration example
├── examples/            # Integration patterns
├── config/              # Firebase configurations
├── scripts/             # Utility scripts
├── seed/                # Test data
└── turbo.json           # Turborepo configuration
```

## Examples

See `/examples` directory for:
- **Turborepo integration** - Full workspace setup
- **Docker Compose integration** - Service dependencies  
- **Makefile integration** - Build system integration

## Features

- ✅ **Turborepo optimized** - Parallel builds and testing
- ✅ **Zero-config setup** - Works out of the box
- ✅ **Multi-platform** - linux/amd64, linux/arm64
- ✅ **CI/CD ready** - Automated Docker Hub publishing
- ✅ **Security hardened** - Non-root user, health checks
- ✅ **Seed data included** - Ready-to-use test accounts

## Links

- **Docker Hub**: [charlesgreen/firebase-emulators](https://hub.docker.com/r/charlesgreen/firebase-emulators)
- **Examples**: [examples/](examples/)
- **Quick Reference**: [QUICKSTART.md](QUICKSTART.md)