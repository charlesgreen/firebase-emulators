# Firebase Emulators Docker

Production-ready Docker container for Firebase emulator suite.

[![CI](https://github.com/charlesgreen/firebase-emulators/actions/workflows/ci.yml/badge.svg)](https://github.com/charlesgreen/firebase-emulators/actions/workflows/ci.yml)
[![Docker Hub](https://img.shields.io/docker/pulls/charlesgreen/firebase-emulators.svg)](https://hub.docker.com/r/charlesgreen/firebase-emulators)

## Quick Start

```bash
docker run -d -p 5170-5179:5170-5179 charlesgreen/firebase-emulators:latest
```

Access the Emulator UI at http://localhost:5179

## Features

- Zero configuration required
- Multi-platform support (linux/amd64, linux/arm64)
- Security hardened with non-root user
- Health checks included
- Optional seed data for testing
- All Firebase emulators pre-configured

## Installation

### Docker

```bash
docker pull charlesgreen/firebase-emulators:latest
```

### Docker Compose

```yaml
services:
  firebase:
    image: charlesgreen/firebase-emulators:latest
    ports:
      - "5170-5179:5170-5179"
    environment:
      - SEED_DATA=true
```

## Port Configuration

| Service   | Port | URL                     |
| --------- | ---- | ----------------------- |
| Hub       | 5170 | `http://localhost:5170` |
| Auth      | 5171 | `http://localhost:5171` |
| Firestore | 5172 | `http://localhost:5172` |
| Hosting   | 5174 | `http://localhost:5174` |
| Storage   | 5175 | `http://localhost:5175` |
| UI        | 5179 | `http://localhost:5179` |

## Environment Variables

| Variable              | Default        | Description                 |
| --------------------- | -------------- | --------------------------- |
| `FIREBASE_PROJECT_ID` | `demo-project` | Firebase project ID         |
| `SEED_DATA`           | `false`        | Load sample data on startup |

## Development

### Prerequisites

- Node.js 20+
- Docker
- npm

### Setup

```bash
npm install
npm run build
npm run test
```

### Build Docker Image

```bash
docker build -t firebase-emulators .
```

### Run Tests

```bash
npm run test
npm run lint
```


## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

MIT License - see the [LICENSE](LICENSE) file for details

## Support

- [Issues](https://github.com/charlesgreen/firebase-emulators/issues)
- [Docker Hub](https://hub.docker.com/r/charlesgreen/firebase-emulators)