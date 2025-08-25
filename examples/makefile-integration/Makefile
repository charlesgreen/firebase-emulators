# Firebase Emulators Integration for Your Project
# Add these targets to your existing Makefile

# Firebase Emulators Configuration
FIREBASE_IMAGE := charlesgreen/firebase-emulators:latest
FIREBASE_CONTAINER := $(PROJECT_NAME)-firebase-emulators
FIREBASE_PROJECT_ID ?= $(PROJECT_NAME)

# Firebase Emulator targets
.PHONY: firebase-start
firebase-start: ## Start Firebase emulators
	@echo "Starting Firebase emulators..."
	@docker run -d \
		--name $(FIREBASE_CONTAINER) \
		-p 5170-5179:5170-5179 \
		-e FIREBASE_PROJECT_ID=$(FIREBASE_PROJECT_ID) \
		-e SEED_DATA=true \
		-e SEED_AUTH=true \
		-e SEED_FIRESTORE=true \
		$(FIREBASE_IMAGE)
	@echo "Waiting for emulators to start..."
	@sleep 5
	@echo "Firebase UI available at: http://localhost:5179"

.PHONY: firebase-stop
firebase-stop: ## Stop Firebase emulators
	@docker stop $(FIREBASE_CONTAINER) 2>/dev/null || true
	@docker rm $(FIREBASE_CONTAINER) 2>/dev/null || true
	@echo "Firebase emulators stopped."

.PHONY: firebase-restart
firebase-restart: firebase-stop firebase-start ## Restart Firebase emulators

.PHONY: firebase-status
firebase-status: ## Check Firebase emulator status
	@echo "=== Firebase Emulator Status ==="
	@docker ps --filter "name=$(FIREBASE_CONTAINER)" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" || echo "Emulators not running"
	@echo ""
	@docker exec $(FIREBASE_CONTAINER) ./scripts/admin-tools.sh status 2>/dev/null || echo "Container not accessible"

.PHONY: firebase-logs
firebase-logs: ## View Firebase emulator logs
	docker logs -f $(FIREBASE_CONTAINER)

.PHONY: firebase-clear
firebase-clear: ## Clear Firebase emulator data
	@docker exec $(FIREBASE_CONTAINER) ./scripts/admin-tools.sh clear || echo "Could not clear data - container may not be running"
	@echo "Firebase emulator data cleared."

.PHONY: firebase-shell
firebase-shell: ## Open shell in Firebase container
	docker exec -it $(FIREBASE_CONTAINER) /bin/bash

# Integration with your project workflows
.PHONY: dev
dev: firebase-start ## Start development environment with Firebase
	@echo "Development environment ready!"
	@echo "Firebase UI: http://localhost:5179"
	@echo "Your app: http://localhost:$(PORT)"
	# Add your dev server start command here
	# npm run dev

.PHONY: test
test: firebase-start ## Run tests with Firebase emulators
	@echo "Running tests with Firebase emulators..."
	# Wait for emulators to be ready
	@timeout 30 bash -c 'until curl -s http://localhost:5179 > /dev/null; do sleep 1; done' || echo "Warning: Emulator UI may not be ready"
	# Set environment variables for your tests
	export FIRESTORE_EMULATOR_HOST=localhost:5172 && \
	export FIREBASE_AUTH_EMULATOR_HOST=localhost:5171 && \
	export FIREBASE_STORAGE_EMULATOR_HOST=localhost:5175 && \
	export FIREBASE_PROJECT_ID=$(FIREBASE_PROJECT_ID) && \
	npm test
	# Optionally clean up after tests
	# $(MAKE) firebase-stop

.PHONY: test-integration
test-integration: firebase-start ## Run integration tests with fresh data
	@echo "Running integration tests with fresh Firebase data..."
	@$(MAKE) firebase-clear
	@sleep 2
	# Run your integration tests here
	export FIRESTORE_EMULATOR_HOST=localhost:5172 && \
	export FIREBASE_AUTH_EMULATOR_HOST=localhost:5171 && \
	export FIREBASE_STORAGE_EMULATOR_HOST=localhost:5175 && \
	export FIREBASE_PROJECT_ID=$(FIREBASE_PROJECT_ID) && \
	npm run test:integration

.PHONY: ci-setup
ci-setup: ## Setup for CI environment
	@echo "Setting up CI with Firebase emulators..."
	@docker run -d \
		--name $(FIREBASE_CONTAINER) \
		-p 5170-5179:5170-5179 \
		-e FIREBASE_PROJECT_ID=$(FIREBASE_PROJECT_ID) \
		-e SEED_DATA=true \
		-e NODE_ENV=test \
		$(FIREBASE_IMAGE)
	@echo "Waiting for emulators to be ready..."
	@timeout 60 bash -c 'until curl -s http://localhost:5179 > /dev/null; do sleep 2; done'

.PHONY: clean
clean: firebase-stop ## Clean up development environment
	@echo "Cleaning up development environment..."
	# Add your cleanup commands here
	docker system prune -f

# Environment setup helpers
.PHONY: firebase-env
firebase-env: ## Show environment variables for Firebase emulators
	@echo "Add these to your .env file:"
	@echo "FIREBASE_PROJECT_ID=$(FIREBASE_PROJECT_ID)"
	@echo "FIRESTORE_EMULATOR_HOST=localhost:5172"
	@echo "FIREBASE_AUTH_EMULATOR_HOST=localhost:5171"
	@echo "FIREBASE_STORAGE_EMULATOR_HOST=localhost:5175"
	@echo "FIREBASE_UI_URL=http://localhost:5179"

.PHONY: firebase-accounts
firebase-accounts: ## Show available test accounts
	@echo "=== Available Test Accounts ==="
	@echo "Admin: admin@example.com / password123"
	@echo "User:  user@example.com / password123"
	@echo "Test:  john.doe@example.com / password123"

# Docker Compose alternative (if you prefer compose)
.PHONY: firebase-compose-start
firebase-compose-start: ## Start Firebase using Docker Compose
	@if [ -f docker-compose.firebase.yml ]; then \
		docker-compose -f docker-compose.firebase.yml up -d; \
	else \
		echo "Creating docker-compose.firebase.yml..."; \
		curl -sSL https://raw.githubusercontent.com/charlesgreen/firebase-emulators/main/examples/docker-compose-integration/docker-compose.yml > docker-compose.firebase.yml; \
		docker-compose -f docker-compose.firebase.yml up -d; \
	fi

.PHONY: firebase-compose-stop
firebase-compose-stop: ## Stop Firebase using Docker Compose
	@docker-compose -f docker-compose.firebase.yml down 2>/dev/null || echo "Compose file not found or services not running"

# Help for Firebase targets
.PHONY: firebase-help
firebase-help: ## Show Firebase-specific help
	@echo "Firebase Emulator Commands:"
	@echo ""
	@grep -E '^firebase-.*:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Environment Variables:"
	@echo "  FIREBASE_PROJECT_ID  - Firebase project ID (default: $(FIREBASE_PROJECT_ID))"
	@echo "  PROJECT_NAME         - Your project name (used for container naming)"
	@echo ""