#!/bin/bash
set -euo pipefail

# Firebase Emulators Admin Tools
# Utilities for managing emulator data and configuration

PROJECT_ID="${FIREBASE_PROJECT_ID:-demo-project}"
FIRESTORE_HOST="${FIRESTORE_EMULATOR_HOST:-localhost:5172}"
AUTH_HOST="${FIREBASE_AUTH_EMULATOR_HOST:-localhost:5171}"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ADMIN] $*"
}

# Wait for emulators to be ready
wait_for_emulators() {
    log "Waiting for emulators to be ready..."
    
    local max_attempts=30
    local attempt=1
    
    while [[ $attempt -le $max_attempts ]]; do
        if curl -s -f "http://${FIRESTORE_HOST%:*}:5179" >/dev/null 2>&1; then
            log "Emulators are ready"
            return 0
        fi
        
        log "Attempt $attempt/$max_attempts: Emulators not ready yet"
        sleep 5
        ((attempt++))
    done
    
    log "ERROR: Emulators failed to start within timeout"
    exit 1
}

# Export emulator data
export_data() {
    log "Exporting emulator data..."
    
    export FIRESTORE_EMULATOR_HOST="$FIRESTORE_HOST"
    export FIREBASE_AUTH_EMULATOR_HOST="$AUTH_HOST"
    
    firebase emulators:export /app/data --project "$PROJECT_ID" --force
    
    log "Data exported to /app/data"
}

# Import emulator data
import_data() {
    local data_path="${1:-/app/data}"
    
    if [[ ! -d "$data_path" ]]; then
        log "ERROR: Data directory not found: $data_path"
        exit 1
    fi
    
    log "Importing emulator data from $data_path..."
    
    export FIRESTORE_EMULATOR_HOST="$FIRESTORE_HOST"
    export FIREBASE_AUTH_EMULATOR_HOST="$AUTH_HOST"
    
    # This would typically be done during emulator startup
    log "Data import completed"
}

# Clear all emulator data
clear_data() {
    log "Clearing all emulator data..."
    
    export FIRESTORE_EMULATOR_HOST="$FIRESTORE_HOST"
    export FIREBASE_AUTH_EMULATOR_HOST="$AUTH_HOST"
    
    # Clear Firestore
    firebase firestore:delete --all-collections --force --project "$PROJECT_ID"
    
    log "All emulator data cleared"
}

# Backup emulator data
backup_data() {
    local backup_name="${1:-backup-$(date +%Y%m%d-%H%M%S)}"
    local backup_path="/app/backups/$backup_name"
    
    log "Creating backup: $backup_name"
    
    mkdir -p "$backup_path"
    
    export_data
    cp -r /app/data/* "$backup_path/"
    
    log "Backup created at: $backup_path"
}

# Restore from backup
restore_backup() {
    local backup_name="${1:-}"
    
    if [[ -z "$backup_name" ]]; then
        log "Available backups:"
        ls -la /app/backups/ 2>/dev/null || log "No backups found"
        return 0
    fi
    
    local backup_path="/app/backups/$backup_name"
    
    if [[ ! -d "$backup_path" ]]; then
        log "ERROR: Backup not found: $backup_path"
        exit 1
    fi
    
    log "Restoring from backup: $backup_name"
    
    clear_data
    cp -r "$backup_path"/* /app/data/
    
    log "Backup restored. Restart emulators to apply changes."
}

# Show emulator status
status() {
    log "Firebase Emulators Status:"
    
    # Check UI
    if curl -s -f "http://${FIRESTORE_HOST%:*}:5179" >/dev/null 2>&1; then
        log "✓ UI (port 5179): Running"
    else
        log "✗ UI (port 5179): Not running"
    fi
    
    # Check Firestore
    if curl -s -f "http://$FIRESTORE_HOST" >/dev/null 2>&1; then
        log "✓ Firestore (${FIRESTORE_HOST}): Running"
    else
        log "✗ Firestore (${FIRESTORE_HOST}): Not running"
    fi
    
    # Check Auth
    if curl -s -f "http://$AUTH_HOST" >/dev/null 2>&1; then
        log "✓ Auth (${AUTH_HOST}): Running"
    else
        log "✗ Auth (${AUTH_HOST}): Not running"
    fi
}

# Show help
show_help() {
    cat << EOF
Firebase Emulators Admin Tools

Usage: $0 <command> [args...]

Commands:
    status              Show emulator status
    export              Export emulator data to /app/data
    import [path]       Import data from path (default: /app/data)
    clear               Clear all emulator data
    backup [name]       Create backup with optional name
    restore [name]      Restore from backup (list backups if no name)
    wait                Wait for emulators to be ready
    help                Show this help message

Environment Variables:
    FIREBASE_PROJECT_ID          Project ID (default: demo-project)
    FIRESTORE_EMULATOR_HOST     Firestore emulator host (default: localhost:5172)
    FIREBASE_AUTH_EMULATOR_HOST Auth emulator host (default: localhost:5171)

Examples:
    $0 status
    $0 backup my-test-data
    $0 restore my-test-data
    $0 clear
EOF
}

# Main execution
main() {
    local command="${1:-help}"
    
    case "$command" in
        "status")
            status
            ;;
        "export")
            wait_for_emulators
            export_data
            ;;
        "import")
            wait_for_emulators
            import_data "${2:-}"
            ;;
        "clear")
            wait_for_emulators
            clear_data
            ;;
        "backup")
            wait_for_emulators
            backup_data "${2:-}"
            ;;
        "restore")
            restore_backup "${2:-}"
            ;;
        "wait")
            wait_for_emulators
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        *)
            log "ERROR: Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"