#!/usr/bin/env bash
#
# deploy-moon.sh - Deploy Docker services to Moon (Synology NAS)
#
# This script:
# 1. Decrypts age-encrypted .env files
# 2. Uploads secrets to Moon's /volume2/docker/secrets/
# 3. Syncs docker-compose files to /volume2/docker/stacks/
# 4. Optionally restarts specified stacks
#
# Usage:
#   ./deploy-moon.sh                    # Deploy all services
#   ./deploy-moon.sh immich             # Deploy specific service
#   ./deploy-moon.sh --restart          # Deploy and restart all services
#   ./deploy-moon.sh --restart immich   # Deploy and restart specific service
#   ./deploy-moon.sh --dry-run          # Show what would be done
#   ./deploy-moon.sh --decrypt-only     # Only decrypt secrets locally (for testing)

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
MOON_HOST="${MOON_HOST:-moon}"
MOON_USER="${MOON_USER:-piotr}"
MOON_SECRETS_DIR="/volume2/docker/secrets"
MOON_STACKS_DIR="/volume2/docker/stacks"
LOCAL_SECRETS_DIR="$REPO_ROOT/secrets/docker/moon"
LOCAL_STACKS_DIR="$REPO_ROOT/hosts/moon/docker"
TEMP_DIR=""
AGE_IDENTITY="${AGE_IDENTITY:-$HOME/.ssh/id_ed25519}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Service list (order matters for dependencies)
SERVICES=(
    "authentik"
    "immich"
    "vaultwarden"
    "media"
    "officeapps"
    "actualbudget"
    "notification"
    "karakeep"
)

# Flags
RESTART=false
DRY_RUN=false
DECRYPT_ONLY=false
SPECIFIC_SERVICE=""

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Cleanup function
cleanup() {
    if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
        log_info "Cleaning up temporary files..."
        rm -rf "$TEMP_DIR"
    fi
}
trap cleanup EXIT

# Parse arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --restart|-r)
                RESTART=true
                shift
                ;;
            --dry-run|-n)
                DRY_RUN=true
                shift
                ;;
            --decrypt-only|-d)
                DECRYPT_ONLY=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            -*)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
            *)
                if [[ -z "$SPECIFIC_SERVICE" ]]; then
                    SPECIFIC_SERVICE="$1"
                else
                    log_error "Multiple services specified. Use one at a time."
                    exit 1
                fi
                shift
                ;;
        esac
    done
}

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] [SERVICE]

Deploy Docker services to Moon (Synology NAS).

Options:
  -r, --restart       Restart services after deployment
  -n, --dry-run       Show what would be done without executing
  -d, --decrypt-only  Only decrypt secrets locally (for testing)
  -h, --help          Show this help message

Services:
  ${SERVICES[*]}

Examples:
  $(basename "$0")                    Deploy all services
  $(basename "$0") immich             Deploy only immich
  $(basename "$0") --restart          Deploy and restart all services
  $(basename "$0") --restart immich   Deploy and restart immich
  $(basename "$0") --dry-run          Show what would be done

Environment variables:
  MOON_HOST       SSH hostname for Moon (default: moon)
  MOON_USER       SSH username (default: piotr)
  AGE_IDENTITY    Path to age identity file (default: ~/.ssh/id_ed25519)
EOF
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."

    # Check for age
    if ! command -v age &> /dev/null; then
        log_error "age is not installed. Install with: brew install age (macOS) or nix-env -iA nixpkgs.age"
        exit 1
    fi

    # Check for SSH connectivity (unless decrypt-only)
    if [[ "$DECRYPT_ONLY" == false && "$DRY_RUN" == false ]]; then
        if ! ssh -o ConnectTimeout=5 "$MOON_USER@$MOON_HOST" "echo 'SSH OK'" &> /dev/null; then
            log_error "Cannot connect to $MOON_USER@$MOON_HOST via SSH"
            log_info "Make sure Moon is reachable and SSH key is configured"
            exit 1
        fi
        log_success "SSH connection to Moon verified"
    fi

    # Check for age identity
    if [[ ! -f "$AGE_IDENTITY" ]]; then
        log_error "Age identity file not found: $AGE_IDENTITY"
        log_info "Set AGE_IDENTITY environment variable or ensure ~/.ssh/id_ed25519 exists"
        exit 1
    fi

    log_success "Prerequisites OK"
}

# Get list of services to deploy
get_services() {
    if [[ -n "$SPECIFIC_SERVICE" ]]; then
        # Validate service name
        local found=false
        for svc in "${SERVICES[@]}"; do
            if [[ "$svc" == "$SPECIFIC_SERVICE" ]]; then
                found=true
                break
            fi
        done
        if [[ "$found" == false ]]; then
            log_error "Unknown service: $SPECIFIC_SERVICE"
            log_info "Available services: ${SERVICES[*]}"
            exit 1
        fi
        echo "$SPECIFIC_SERVICE"
    else
        echo "${SERVICES[@]}"
    fi
}

# Decrypt secrets
decrypt_secrets() {
    local services=("$@")
    TEMP_DIR=$(mktemp -d)

    log_info "Decrypting secrets to $TEMP_DIR..."

    for service in "${services[@]}"; do
        local secret_file="$LOCAL_SECRETS_DIR/${service}.env.age"
        local output_file="$TEMP_DIR/${service}.env"

        if [[ -f "$secret_file" ]]; then
            if [[ "$DRY_RUN" == true ]]; then
                log_info "[DRY-RUN] Would decrypt: $secret_file -> $output_file"
            else
                age --decrypt -i "$AGE_IDENTITY" -o "$output_file" "$secret_file"
                chmod 600 "$output_file"
                log_success "Decrypted: ${service}.env"
            fi
        else
            log_warn "No encrypted secrets for $service (file not found: $secret_file)"
        fi
    done
}

# Upload secrets to Moon
upload_secrets() {
    local services=("$@")

    log_info "Uploading secrets to Moon..."

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Would create directory: $MOON_SECRETS_DIR"
        log_info "[DRY-RUN] Would upload decrypted .env files"
        return
    fi

    # Create secrets directory on Moon
    ssh "$MOON_USER@$MOON_HOST" "mkdir -p $MOON_SECRETS_DIR && chmod 700 $MOON_SECRETS_DIR"

    # Upload each decrypted secret
    for service in "${services[@]}"; do
        local secret_file="$TEMP_DIR/${service}.env"

        if [[ -f "$secret_file" ]]; then
            scp -q "$secret_file" "$MOON_USER@$MOON_HOST:$MOON_SECRETS_DIR/"
            ssh "$MOON_USER@$MOON_HOST" "chmod 600 $MOON_SECRETS_DIR/${service}.env"
            log_success "Uploaded: ${service}.env"
        fi
    done
}

# Sync docker-compose files to Moon
sync_compose_files() {
    local services=("$@")

    log_info "Syncing docker-compose files to Moon..."

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Would create directory: $MOON_STACKS_DIR"
        for service in "${services[@]}"; do
            log_info "[DRY-RUN] Would sync: $LOCAL_STACKS_DIR/$service/ -> $MOON_STACKS_DIR/$service/"
        done
        return
    fi

    # Create stacks directory on Moon
    ssh "$MOON_USER@$MOON_HOST" "mkdir -p $MOON_STACKS_DIR"

    # Sync each service's compose files
    for service in "${services[@]}"; do
        local source_dir="$LOCAL_STACKS_DIR/$service"

        if [[ -d "$source_dir" ]]; then
            # Create service directory on Moon
            ssh "$MOON_USER@$MOON_HOST" "mkdir -p $MOON_STACKS_DIR/$service"

            # Sync compose file and any other config files (but not .env*)
            rsync -av --exclude '*.env' --exclude '*.env.*' --exclude '.env*' \
                "$source_dir/" "$MOON_USER@$MOON_HOST:$MOON_STACKS_DIR/$service/"

            log_success "Synced: $service/"
        else
            log_warn "No compose files for $service (directory not found: $source_dir)"
        fi
    done
}

# Restart services on Moon
restart_services() {
    local services=("$@")

    log_info "Restarting services on Moon..."

    if [[ "$DRY_RUN" == true ]]; then
        for service in "${services[@]}"; do
            log_info "[DRY-RUN] Would restart: docker-compose -f $MOON_STACKS_DIR/$service/docker-compose.yaml up -d"
        done
        return
    fi

    for service in "${services[@]}"; do
        local compose_file="$MOON_STACKS_DIR/$service/docker-compose.yaml"

        # Check if compose file exists on Moon
        if ssh "$MOON_USER@$MOON_HOST" "test -f $compose_file"; then
            log_info "Restarting $service..."
            ssh "$MOON_USER@$MOON_HOST" "cd $MOON_STACKS_DIR/$service && docker-compose up -d"
            log_success "Restarted: $service"
        else
            log_warn "No compose file for $service on Moon (skipping restart)"
        fi
    done
}

# Main function
main() {
    parse_args "$@"

    echo ""
    echo "======================================"
    echo "  Moon Deployment Script"
    echo "======================================"
    echo ""

    check_prerequisites

    # Get services to deploy
    local services
    read -ra services <<< "$(get_services)"

    log_info "Services to deploy: ${services[*]}"
    echo ""

    # Decrypt secrets
    decrypt_secrets "${services[@]}"

    if [[ "$DECRYPT_ONLY" == true ]]; then
        log_success "Secrets decrypted to: $TEMP_DIR"
        log_info "Files will be cleaned up on exit"
        echo ""
        ls -la "$TEMP_DIR"
        echo ""
        read -p "Press Enter to cleanup and exit..."
        exit 0
    fi

    # Upload secrets to Moon
    upload_secrets "${services[@]}"

    # Sync compose files
    sync_compose_files "${services[@]}"

    # Restart services if requested
    if [[ "$RESTART" == true ]]; then
        restart_services "${services[@]}"
    fi

    echo ""
    log_success "Deployment complete!"
    echo ""

    if [[ "$RESTART" == false ]]; then
        log_info "Services were not restarted. To restart, run with --restart flag"
        log_info "Or manually restart on Moon with: docker-compose -f /volume2/docker/stacks/<service>/docker-compose.yaml up -d"
    fi
}

main "$@"
