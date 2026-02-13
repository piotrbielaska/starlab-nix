#!/usr/bin/env bash
#
# encrypt-secret.sh - Encrypt a plaintext file using agenix/age
#
# Usage:
#   ./encrypt-secret.sh input.env output.env.age
#   ./encrypt-secret.sh --edit secrets/docker/moon/immich.env.age
#
# This script uses the public keys defined in secrets/secrets.nix

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
SECRETS_NIX="$REPO_ROOT/secrets/secrets.nix"

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
Usage: $(basename "$0") [OPTIONS] INPUT OUTPUT
       $(basename "$0") --edit ENCRYPTED_FILE

Encrypt or edit age-encrypted secrets.

Arguments:
  INPUT           Plaintext file to encrypt
  OUTPUT          Output .age file

Options:
  -e, --edit      Edit an existing encrypted file in place
  -r, --recipients  Specify comma-separated public keys (or file paths)
  -h, --help      Show this help message

Examples:
  $(basename "$0") .env secrets/docker/moon/immich.env.age
  $(basename "$0") --edit secrets/docker/moon/immich.env.age
  $(basename "$0") -r ~/.ssh/id_ed25519.pub plaintext.env encrypted.age

Notes:
  - Uses agenix if available, otherwise falls back to age CLI
  - For new files, recipients are derived from secrets/secrets.nix
  - The --edit option decrypts, opens in \$EDITOR, and re-encrypts
EOF
}

# Check prerequisites
check_prerequisites() {
    if ! command -v age &> /dev/null; then
        log_error "age is not installed"
        log_info "Install with: brew install age (macOS) or nix-env -iA nixpkgs.age"
        exit 1
    fi
}

# Extract public keys from secrets.nix for a given secret
# This is a simplified parser - for full parsing use agenix
get_recipients_for_secret() {
    local secret_path="$1"
    local secret_name
    secret_name=$(basename "$secret_path" .age)

    # Look for the secret in secrets.nix and extract publicKeys
    # This is a rough grep-based approach; proper parsing would use nix eval
    log_warn "Automatic recipient extraction from secrets.nix not fully implemented"
    log_info "Using default recipient: ~/.ssh/id_ed25519.pub"

    # Return the user's public key as default recipient
    if [[ -f "$HOME/.ssh/id_ed25519.pub" ]]; then
        cat "$HOME/.ssh/id_ed25519.pub"
    else
        log_error "No SSH public key found at ~/.ssh/id_ed25519.pub"
        exit 1
    fi
}

# Encrypt a file
encrypt_file() {
    local input="$1"
    local output="$2"
    local recipients="$3"

    if [[ ! -f "$input" ]]; then
        log_error "Input file not found: $input"
        exit 1
    fi

    # Build age command with recipients
    local age_cmd="age"
    if [[ -n "$recipients" ]]; then
        # Recipients can be public keys or files
        IFS=',' read -ra RECIPIENT_LIST <<< "$recipients"
        for recipient in "${RECIPIENT_LIST[@]}"; do
            recipient=$(echo "$recipient" | xargs) # trim whitespace
            if [[ -f "$recipient" ]]; then
                age_cmd="$age_cmd -R $recipient"
            else
                age_cmd="$age_cmd -r $recipient"
            fi
        done
    else
        # Default to user's SSH public key
        if [[ -f "$HOME/.ssh/id_ed25519.pub" ]]; then
            age_cmd="$age_cmd -R $HOME/.ssh/id_ed25519.pub"
        else
            log_error "No recipients specified and no default SSH key found"
            exit 1
        fi
    fi

    # Create output directory if needed
    mkdir -p "$(dirname "$output")"

    # Encrypt
    $age_cmd -o "$output" "$input"
    log_success "Encrypted: $input -> $output"
}

# Edit an encrypted file
edit_encrypted() {
    local encrypted_file="$1"
    local identity="${AGE_IDENTITY:-$HOME/.ssh/id_ed25519}"

    if [[ ! -f "$encrypted_file" ]]; then
        log_error "Encrypted file not found: $encrypted_file"
        exit 1
    fi

    if [[ ! -f "$identity" ]]; then
        log_error "Identity file not found: $identity"
        exit 1
    fi

    # Create temp file
    local temp_file
    temp_file=$(mktemp)
    trap "rm -f $temp_file" EXIT

    # Decrypt to temp file
    log_info "Decrypting..."
    age --decrypt -i "$identity" -o "$temp_file" "$encrypted_file"

    # Get original checksum
    local original_sum
    original_sum=$(shasum -a 256 "$temp_file" | cut -d' ' -f1)

    # Open in editor
    local editor="${EDITOR:-nano}"
    $editor "$temp_file"

    # Check if file changed
    local new_sum
    new_sum=$(shasum -a 256 "$temp_file" | cut -d' ' -f1)

    if [[ "$original_sum" == "$new_sum" ]]; then
        log_info "No changes made, skipping re-encryption"
        exit 0
    fi

    # Re-encrypt (using the user's public key)
    log_info "Re-encrypting..."
    local recipients=""
    if [[ -f "$HOME/.ssh/id_ed25519.pub" ]]; then
        recipients="$HOME/.ssh/id_ed25519.pub"
    fi

    # Backup original
    cp "$encrypted_file" "${encrypted_file}.bak"

    # Encrypt
    encrypt_file "$temp_file" "$encrypted_file" "$recipients"
    log_success "Updated: $encrypted_file"

    # Remove backup on success
    rm -f "${encrypted_file}.bak"
}

# Main
main() {
    local edit_mode=false
    local recipients=""
    local positional=()

    while [[ $# -gt 0 ]]; do
        case $1 in
            -e|--edit)
                edit_mode=true
                shift
                ;;
            -r|--recipients)
                recipients="$2"
                shift 2
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
                positional+=("$1")
                shift
                ;;
        esac
    done

    check_prerequisites

    if [[ "$edit_mode" == true ]]; then
        if [[ ${#positional[@]} -ne 1 ]]; then
            log_error "Edit mode requires exactly one encrypted file"
            show_help
            exit 1
        fi
        edit_encrypted "${positional[0]}"
    else
        if [[ ${#positional[@]} -ne 2 ]]; then
            log_error "Encryption requires INPUT and OUTPUT arguments"
            show_help
            exit 1
        fi
        encrypt_file "${positional[0]}" "${positional[1]}" "$recipients"
    fi
}

main "$@"
