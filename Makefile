# Firebase Emulators Makefile
# Production-ready commands for development and deployment

# Configuration
DOCKER_IMAGE := charlesgreen/firebase-emulators
CONTAINER_NAME := firebase-emulators
PROJECT_ID := demo-project

# Default target
.PHONY: help
help: ## Show this help message
	@echo "Firebase Emulators - Available Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""

# Quick start commands
.PHONY: start
start: ## Start Firebase emulators (Docker Compose)
	docker-compose up -d
	@echo "Firebase emulators started!"
	@echo "UI available at: http://localhost:5179"

.PHONY: start-with-seed
start-with-seed: ## Start with sample data loaded
	SEED_DATA=true SEED_AUTH=true SEED_FIRESTORE=true docker-compose up -d
	@echo "Firebase emulators started with seed data!"
	@echo "UI available at: http://localhost:5179"
	@echo "Test accounts: admin@example.com / password123"

.PHONY: stop
stop: ## Stop Firebase emulators
	docker-compose down
	@echo "Firebase emulators stopped."

.PHONY: restart
restart: stop start ## Restart Firebase emulators

.PHONY: status
status: ## Show emulator status
	@echo "=== Docker Container Status ==="
	@docker ps --filter "name=$(CONTAINER_NAME)" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
	@echo ""
	@echo "=== Emulator Health ==="
	@docker exec $(CONTAINER_NAME) ./scripts/admin-tools.sh status 2>/dev/null || echo "Container not running or not ready"

# Development commands
.PHONY: logs
logs: ## View emulator logs
	docker-compose logs -f

.PHONY: shell
shell: ## Open shell in emulator container
	docker exec -it $(CONTAINER_NAME) /bin/bash

.PHONY: clear-data
clear-data: ## Clear all emulator data
	docker exec $(CONTAINER_NAME) ./scripts/admin-tools.sh clear
	@echo "All emulator data cleared."

.PHONY: backup
backup: ## Create backup of current data (usage: make backup BACKUP_NAME=my-backup)
	$(eval BACKUP_NAME ?= backup-$(shell date +%Y%m%d-%H%M%S))
	docker exec $(CONTAINER_NAME) ./scripts/admin-tools.sh backup $(BACKUP_NAME)
	@echo "Backup created: $(BACKUP_NAME)"

.PHONY: restore
restore: ## Restore backup (usage: make restore BACKUP_NAME=my-backup)
	$(if $(BACKUP_NAME), \
		docker exec $(CONTAINER_NAME) ./scripts/admin-tools.sh restore $(BACKUP_NAME), \
		$(error BACKUP_NAME is required. Usage: make restore BACKUP_NAME=my-backup))

# Docker image management
.PHONY: pull
pull: ## Pull latest Docker image
	docker pull $(DOCKER_IMAGE):latest
	@echo "Latest image pulled successfully."

.PHONY: build
build: ## Build Docker image locally
	docker build -t $(DOCKER_IMAGE):local .
	@echo "Local image built: $(DOCKER_IMAGE):local"

.PHONY: build-no-cache
build-no-cache: ## Build Docker image without cache
	docker build --no-cache -t $(DOCKER_IMAGE):local .
	@echo "Local image built (no cache): $(DOCKER_IMAGE):local"

# Testing and CI commands
.PHONY: test-build
test-build: ## Test Docker build
	docker build -t $(DOCKER_IMAGE):test .
	@echo "Test build completed successfully."

.PHONY: test-run
test-run: ## Test run container
	docker run -d --name $(CONTAINER_NAME)-test -p 6170-6179:5170-5179 $(DOCKER_IMAGE):test
	@echo "Waiting for emulators to start..."
	@sleep 10
	@curl -f http://localhost:6179 > /dev/null && echo "Health check passed!" || echo "Health check failed!"
	docker stop $(CONTAINER_NAME)-test
	docker rm $(CONTAINER_NAME)-test

.PHONY: ci-test
ci-test: test-build test-run ## Run full CI test suite

# Cleanup commands
.PHONY: clean
clean: ## Remove stopped containers and unused images
	docker container prune -f
	docker image prune -f
	@echo "Cleanup completed."

.PHONY: clean-all
clean-all: stop ## Stop everything and clean up
	docker-compose down -v --remove-orphans
	docker container prune -f
	docker image prune -f
	docker volume prune -f
	@echo "Full cleanup completed."

# Utility commands
.PHONY: ports
ports: ## Show port mappings
	@echo "=== Firebase Emulator Ports ==="
	@echo "UI Dashboard:  http://localhost:5179"
	@echo "Auth:          http://localhost:5171"
	@echo "Firestore:     http://localhost:5172"
	@echo "Storage:       http://localhost:5175"
	@echo "Hosting:       http://localhost:5174"
	@echo "Hub:           http://localhost:5170"

.PHONY: open
open: ## Open Firebase UI in browser
	@command -v open >/dev/null 2>&1 && open http://localhost:5179 || \
	 command -v xdg-open >/dev/null 2>&1 && xdg-open http://localhost:5179 || \
	 echo "Please open http://localhost:5179 in your browser"

.PHONY: quick-setup
quick-setup: ## One-command setup for new projects
	@echo "Setting up Firebase emulators for your project..."
	@if [ ! -f .env ]; then \
		echo "FIREBASE_PROJECT_ID=$(PROJECT_ID)" > .env; \
		echo "SEED_DATA=false" >> .env; \
		echo "Created .env file"; \
	fi
	@echo "Setup complete! Run 'make start' to begin."

# Docker Compose override for different environments
.PHONY: start-dev
start-dev: ## Start in development mode with seed data
	COMPOSE_FILE=docker-compose.yml:docker-compose.dev.yml docker-compose up -d
	@echo "Development environment started with debugging enabled"

.PHONY: start-prod
start-prod: ## Start in production mode
	COMPOSE_FILE=docker-compose.yml:docker-compose.prod.yml docker-compose up -d
	@echo "Production environment started"

# Integration examples
.PHONY: examples
examples: ## Show integration examples
	@echo "=== Integration Examples ==="
	@echo ""
	@echo "1. Add to package.json scripts:"
	@echo '   "emulators": "make start",'
	@echo '   "emulators:stop": "make stop",'
	@echo '   "emulators:clean": "make clean-all"'
	@echo ""
	@echo "2. Turborepo integration:"
	@echo '   See examples/turborepo-integration/'
	@echo ""
	@echo "3. GitHub Actions:"
	@echo '   services:'
	@echo '     firebase:'
	@echo '       image: $(DOCKER_IMAGE):latest'
	@echo '       ports: ["5170-5179:5170-5179"]'
	@echo ""
	@echo "4. Docker Compose integration:"
	@echo '   See examples/docker-compose-integration/'