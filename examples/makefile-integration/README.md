# Makefile Integration Example

This example shows how to add Firebase Emulators to your project's Makefile for streamlined development workflows.

## Quick Setup

1. **Copy the Makefile targets:**
   ```bash
   curl -sSL https://raw.githubusercontent.com/charlesgreen/firebase-emulators/main/examples/makefile-integration/Makefile >> Makefile
   ```

2. **Set your project variables:**
   ```makefile
   # Add to the top of your Makefile
   PROJECT_NAME := my-awesome-app
   FIREBASE_PROJECT_ID := my-firebase-project
   ```

3. **Start using Firebase commands:**
   ```bash
   make firebase-start
   make test
   make firebase-stop
   ```

## Available Commands

### Core Firebase Commands

| Command | Description |
|---------|-------------|
| `firebase-start` | Start Firebase emulators with seed data |
| `firebase-stop` | Stop and remove Firebase containers |
| `firebase-restart` | Restart Firebase emulators |
| `firebase-status` | Check emulator status and health |

### Development Workflow

| Command | Description |
|---------|-------------|
| `dev` | Start development environment with Firebase |
| `test` | Run tests with Firebase emulators |
| `test-integration` | Run integration tests with fresh data |
| `firebase-clear` | Clear all emulator data |

### Utilities

| Command | Description |
|---------|-------------|
| `firebase-env` | Show environment variables to add to .env |
| `firebase-accounts` | Show available test accounts |
| `firebase-logs` | View emulator logs |
| `firebase-shell` | Open shell in emulator container |

## Integration Patterns

### Pattern 1: Development Dependencies

```makefile
dev: firebase-start
	@echo "Starting development server..."
	npm run dev
```

### Pattern 2: Test Dependencies

```makefile
test: firebase-start
	@timeout 30 bash -c 'until curl -s http://localhost:5179 > /dev/null; do sleep 1; done'
	export FIRESTORE_EMULATOR_HOST=localhost:5172 && npm test
```

### Pattern 3: CI Integration

```makefile
ci-test: ci-setup
	npm run test:ci
	$(MAKE) firebase-stop
```

## Environment Variables

The Makefile automatically sets up these environment variables for your tests:

```bash
FIRESTORE_EMULATOR_HOST=localhost:5172
FIREBASE_AUTH_EMULATOR_HOST=localhost:5171
FIREBASE_STORAGE_EMULATOR_HOST=localhost:5175
FIREBASE_PROJECT_ID=your-project-id
```

## Customization

### Project-Specific Variables

```makefile
# Customize these for your project
PROJECT_NAME := my-app
FIREBASE_PROJECT_ID := my-firebase-project
PORT := 3000
```

### Custom Test Targets

```makefile
test-e2e: firebase-start
	@echo "Running E2E tests..."
	export FIRESTORE_EMULATOR_HOST=localhost:5172 && \
	npx playwright test
	$(MAKE) firebase-stop
```

### Docker Compose Alternative

```makefile
firebase-start-compose:
	docker-compose -f docker-compose.firebase.yml up -d
```

## Best Practices

1. **Always check emulator readiness** before running tests
2. **Clean up containers** in CI environments
3. **Use consistent project naming** across environments
4. **Set appropriate timeouts** for emulator startup
5. **Include help targets** for team onboarding

## Example Project Integration

```makefile
# Your project Makefile
PROJECT_NAME := awesome-app
FIREBASE_PROJECT_ID := awesome-app-dev

include firebase.mk

install:
	npm install

dev: firebase-start install
	npm run dev

test: firebase-start
	npm run test:unit
	$(MAKE) firebase-stop

deploy: test
	firebase deploy

clean: firebase-stop
	rm -rf node_modules dist

.PHONY: install dev test deploy clean
```