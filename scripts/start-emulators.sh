#!/bin/bash
set -euo pipefail

# Firebase Emulators Startup Script
# Optimized with error handling and environment variable configuration

# Configuration from environment variables
PROJECT_ID="${FIREBASE_PROJECT_ID:-demo-project}"
AUTH_PORT="${FIREBASE_AUTH_PORT:-5171}"
FIRESTORE_PORT="${FIREBASE_FIRESTORE_PORT:-5172}"
HOSTING_PORT="${FIREBASE_HOSTING_PORT:-5174}"
STORAGE_PORT="${FIREBASE_STORAGE_PORT:-5175}"
UI_PORT="${FIREBASE_UI_PORT:-5179}"
HUB_PORT="${FIREBASE_EMULATOR_HUB_PORT:-5170}"

# Feature flags
ENABLE_AUTH="${ENABLE_AUTH:-true}"
ENABLE_FIRESTORE="${ENABLE_FIRESTORE:-true}"
ENABLE_HOSTING="${ENABLE_HOSTING:-true}"
ENABLE_STORAGE="${ENABLE_STORAGE:-true}"

# Seed data flags
SEED_DATA="${SEED_DATA:-false}"
SEED_AUTH="${SEED_AUTH:-false}"
SEED_FIRESTORE="${SEED_FIRESTORE:-false}"

# Logging configuration
LOG_FILE="/app/logs/emulator.log"
mkdir -p "$(dirname "$LOG_FILE")"

# Logging function
log() {
    local level="$1"
    shift
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*" | tee -a "$LOG_FILE"
}

# Error handling
trap 'log ERROR "Script failed at line $LINENO"' ERR
trap 'cleanup' EXIT INT TERM

cleanup() {
    log INFO "Shutting down Firebase emulators..."
    # Kill any running Firebase processes
    pkill -f firebase || true
    log INFO "Cleanup completed"
}

# Validate configuration
validate_config() {
    log INFO "Validating configuration..."
    
    if [[ ! -f "/app/config/firebase.json" ]]; then
        log ERROR "firebase.json not found in /app/config/"
        exit 1
    fi
    
    # Validate JSON syntax
    if ! jq empty "/app/config/firebase.json" 2>/dev/null; then
        log ERROR "Invalid JSON in firebase.json"
        exit 1
    fi
    
    log INFO "Configuration validated successfully"
}

# Wait for emulator to be ready
wait_for_emulator() {
    local service="$1"
    local port="$2"
    local max_attempts=30
    local attempt=1
    
    log INFO "Waiting for $service emulator on port $port..."
    
    while [[ $attempt -le $max_attempts ]]; do
        if curl -s -f "http://localhost:$port" >/dev/null 2>&1; then
            log INFO "$service emulator is ready"
            return 0
        fi
        
        log DEBUG "Attempt $attempt/$max_attempts: $service not ready yet"
        sleep 2
        ((attempt++))
    done
    
    log ERROR "$service emulator failed to start within timeout"
    return 1
}

# Import seed data
import_seed_data() {
    if [[ "$SEED_DATA" != "true" ]]; then
        log INFO "Seed data import disabled"
        return 0
    fi
    
    log INFO "Starting seed data import..."
    
    # Import Firestore seed data
    if [[ "$SEED_FIRESTORE" == "true" && "$ENABLE_FIRESTORE" == "true" ]]; then
        if [[ -f "/app/seed/firestore.json" ]]; then
            log INFO "Importing Firestore seed data..."
            
            # Wait for Firestore emulator
            wait_for_emulator "Firestore" "$FIRESTORE_PORT"
            
            # Import data using Firebase CLI
            FIRESTORE_EMULATOR_HOST="localhost:$FIRESTORE_PORT" \
            firebase firestore:delete --all-collections --force --project "$PROJECT_ID" 2>&1 | tee -a "$LOG_FILE"
            
            # Import seed data (implementation depends on your data format)
            log INFO "Firestore seed data would be imported here"
            # Add your specific import logic here
        else
            log WARN "Firestore seed data file not found: /app/seed/firestore.json"
        fi
    fi
    
    # Import Auth seed data
    if [[ "$SEED_AUTH" == "true" && "$ENABLE_AUTH" == "true" ]]; then
        if [[ -f "/app/seed/auth.json" ]]; then
            log INFO "Importing Auth seed data..."
            wait_for_emulator "Auth" "$AUTH_PORT"
            # Add your auth import logic here
        else
            log WARN "Auth seed data file not found: /app/seed/auth.json"
        fi
    fi
    
    log INFO "Seed data import completed"
}

# Main startup function
start_emulators() {
    log INFO "Starting Firebase emulators for project: $PROJECT_ID"
    log INFO "Emulator ports: Auth=$AUTH_PORT, Firestore=$FIRESTORE_PORT, Hosting=$HOSTING_PORT, Storage=$STORAGE_PORT, UI=$UI_PORT"
    
    # Change to config directory
    cd /app/config
    
    # Set environment variables for Firebase CLI
    export GOOGLE_CLOUD_PROJECT="$PROJECT_ID"
    export FIREBASE_PROJECT="$PROJECT_ID"
    
    # Build emulator command
    local emulator_cmd="firebase emulators:start"
    emulator_cmd+=" --project $PROJECT_ID"
    emulator_cmd+=" --import /app/data"
    emulator_cmd+=" --export-on-exit /app/data"
    
    # Add individual emulator flags based on configuration
    local emulators=()
    
    if [[ "$ENABLE_AUTH" == "true" ]]; then
        emulators+=("auth")
    fi
    
    if [[ "$ENABLE_FIRESTORE" == "true" ]]; then
        emulators+=("firestore")
    fi
    
    if [[ "$ENABLE_HOSTING" == "true" ]]; then
        emulators+=("hosting")
    fi
    
    if [[ "$ENABLE_STORAGE" == "true" ]]; then
        emulators+=("storage")
    fi
    
    # Always enable UI for monitoring
    emulators+=("ui")
    
    # Join emulators array
    local emulators_list
    emulators_list=$(IFS=','; echo "${emulators[*]}")
    emulator_cmd+=" --only $emulators_list"
    
    log INFO "Starting emulators: $emulators_list"
    log INFO "Command: $emulator_cmd"
    
    # Start emulators
    exec $emulator_cmd 2>&1 | tee -a "$LOG_FILE"
}

# Main execution
main() {
    log INFO "Firebase Emulators starting up..."
    log INFO "Project ID: $PROJECT_ID"
    log INFO "Working directory: $(pwd)"
    
    validate_config
    
    # Start emulators in background for seed data import
    if [[ "$SEED_DATA" == "true" ]]; then
        log INFO "Starting emulators with seed data import..."
        start_emulators &
        local emulator_pid=$!
        
        # Wait a bit for emulators to start
        sleep 10
        
        # Import seed data
        import_seed_data
        
        # Wait for the main process
        wait $emulator_pid
    else
        # Start emulators normally
        start_emulators
    fi
}

# Run main function
main "$@"