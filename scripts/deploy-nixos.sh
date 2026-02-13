#!/usr/bin/env bash
#
# deploy-nixos.sh - Wrapper for colmena deployment
#
# This script provides a simpler interface to colmena for deploying NixOS hosts.
#
# Usage:
#   ./deploy-nixos.sh              # Deploy all NixOS hosts
#   ./deploy-nixos.sh rust         # Deploy specific host
#   ./deploy-nixos.sh --check      # Check configurations without deploying
#   ./deploy-nixos.sh --repl       # Enter nix repl for debugging

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] [HOST]

Deploy NixOS configurations using colmena.

Arguments:
  HOST            Specific host to deploy (e.g., rust, starship)

Options:
  -c, --check     Check configuration without deploying
  -b, --build     Build without deploying
  -r, --repl      Enter nix repl for debugging
  -l, --local     Deploy to local machine (for starship)
  -h, --help      Show this help message

Examples:
  $(basename "$0")              Deploy all hosts
  $(basename "$0") rust         Deploy only rust
  $(basename "$0") --check      Validate all configurations
  $(basename "$0") --local      Deploy starship locally

Hosts:
  rust      - NixOS VM on Mars (Proxmox)
  starship  - MacBook Pro M1 (local deployment only)
  mars      - Dell Optiplex (after NixOS migration)
  jupiter   - H1 Desktop (after NixOS installation)
EOF
}

# Check prerequisites
check_prerequisites() {
    if ! command -v colmena &> /dev/null; then
        log_error "colmena is not installed"
        log_info "Install with: nix-env -iA nixpkgs.colmena"
        exit 1
    fi

    if ! command -v nix &> /dev/null; then
        log_error "nix is not installed"
        exit 1
    fi
}

# Main
main() {
    local check_mode=false
    local build_mode=false
    local repl_mode=false
    local local_mode=false
    local target_host=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            -c|--check)
                check_mode=true
                shift
                ;;
            -b|--build)
                build_mode=true
                shift
                ;;
            -r|--repl)
                repl_mode=true
                shift
                ;;
            -l|--local)
                local_mode=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            -*)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
            *)
                target_host="$1"
                shift
                ;;
        esac
    done

    check_prerequisites
    cd "$REPO_ROOT"

    if [[ "$repl_mode" == true ]]; then
        log_info "Entering nix repl..."
        nix repl --file flake.nix
        exit 0
    fi

    if [[ "$check_mode" == true ]]; then
        log_info "Checking flake..."
        nix flake check
        log_success "Flake check passed"
        exit 0
    fi

    if [[ "$build_mode" == true ]]; then
        log_info "Building configurations..."
        if [[ -n "$target_host" ]]; then
            colmena build --on "$target_host"
        else
            colmena build
        fi
        log_success "Build complete"
        exit 0
    fi

    # Deploy
    if [[ "$local_mode" == true ]] || [[ "$target_host" == "starship" ]]; then
        log_info "Deploying locally (starship)..."
        colmena apply-local --sudo
    elif [[ -n "$target_host" ]]; then
        log_info "Deploying to $target_host..."
        colmena apply --on "$target_host"
    else
        log_info "Deploying to all hosts..."
        colmena apply
    fi

    log_success "Deployment complete"
}

main "$@"
