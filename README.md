# StarLAB

My homelab infrastructure managed with NixOS, nix-darwin, and Docker.

All devices and VMs are named after objects in the Solar System.

## Overview

This repository is the single source of truth for my homelab infrastructure:

- **NixOS hosts** are managed declaratively with Colmena
- **macOS hosts** (nix-darwin) are managed with home-manager
- **Docker services** (Synology) use encrypted secrets and deployment scripts
- **Secrets** are encrypted with agenix (age encryption)

## Hosts

| Host | Type | Hardware | Purpose |
|------|------|----------|---------|
| **rust** | NixOS VM | Mars/Proxmox | Test VM, Dawarich, Airtrail |
| **starship** | macOS | MacBook Pro M1 | Primary workstation |
| **moon** | Synology | DS1522+ | NAS, Docker services |
| **mars** | Proxmox→NixOS | Dell Optiplex i3-6100T | Home Assistant, Authentik |
| **jupiter** | NixOS | H1 Desktop | Gaming, transcoding |

## Quick Start

### Prerequisites

```bash
# Install Nix (if not already installed)
curl -L https://nixos.org/nix/install | sh

# Install required tools
nix-env -iA nixpkgs.colmena nixpkgs.age
```

### Deploy NixOS Hosts

```bash
# Deploy all NixOS hosts
./scripts/deploy-nixos.sh

# Deploy specific host
./scripts/deploy-nixos.sh rust

# Check configurations without deploying
./scripts/deploy-nixos.sh --check
```

### Deploy to Synology (Moon)

```bash
# Deploy all Docker services
./scripts/deploy-moon.sh

# Deploy specific service
./scripts/deploy-moon.sh immich

# Deploy and restart services
./scripts/deploy-moon.sh --restart
```

### Manage Secrets

```bash
# Encrypt a new secret
./scripts/encrypt-secret.sh plaintext.env secrets/docker/moon/service.env.age

# Edit existing encrypted secret
./scripts/encrypt-secret.sh --edit secrets/docker/moon/service.env.age
```

## Directory Structure

```
starlab/
├── flake.nix                    # Nix flake configuration
├── flake.lock
├── README.md
│
├── docs/                        # Documentation
│   ├── inventory.md             # Hardware inventory
│   ├── modernization-plan.md    # Infrastructure modernization plan
│   └── services/                # Service documentation
│
├── secrets/
│   ├── secrets.nix              # Agenix key registry
│   ├── nixos/                   # NixOS secrets (agenix managed)
│   │   ├── rust/
│   │   └── mars/
│   └── docker/                  # Docker .env secrets (age encrypted)
│       └── moon/
│
├── hosts/
│   ├── common/                  # Shared NixOS modules
│   ├── rust/                    # NixOS VM config
│   ├── starship/                # macOS config
│   ├── jupiter/                 # H1 Desktop config
│   └── moon/                    # Synology Docker configs
│       ├── README.md
│       └── docker/
│           ├── immich/
│           ├── vaultwarden/
│           ├── media/
│           └── ...
│
├── home/                        # Home-manager configs
│   ├── piotr/
│   └── ...
│
└── scripts/
    ├── deploy-moon.sh           # Synology deployment
    ├── deploy-nixos.sh          # NixOS deployment wrapper
    └── encrypt-secret.sh        # Secret encryption helper
```

## Secrets Management

Secrets are encrypted using [agenix](https://github.com/ryantm/agenix) (which uses [age](https://age-encryption.org/) encryption).

### How it works

1. **NixOS secrets**: Encrypted with agenix, decrypted automatically at system activation
2. **Docker secrets**: Encrypted with age, decrypted by `deploy-moon.sh` before upload

### Adding a new host's key

1. Get the host's SSH public key:
   ```bash
   ssh-keyscan -t ed25519 <hostname> 2>/dev/null | cut -d' ' -f2-
   ```

2. Add the key to `secrets/secrets.nix`

3. Re-encrypt secrets that the host needs access to

## Services

### Moon (Synology) Services

| Service | Port | Description |
|---------|------|-------------|
| Immich | 2283 | Photo management |
| Jellyfin | 8096 | Media streaming |
| Vaultwarden | 8122 | Password manager |
| Sonarr | 8989 | TV automation |
| Radarr | 7878 | Movie automation |
| Lidarr | 8686 | Music automation |
| Prowlarr | 9696 | Indexer manager |
| Audiobookshelf | 13378 | Audiobook server |
| Actual Budget | 5006 | Budgeting |
| Hoarder | 4444 | Bookmark manager |

### Mars Services (planned)

| Service | Description |
|---------|-------------|
| Home Assistant | Home automation |
| Authentik | SSO/Identity provider |
| AdGuard Home | DNS filtering |
| Uptime Kuma | Monitoring |

## Network

| VLAN | Network | Purpose |
|------|---------|---------|
| 1 | 10.1.100.0/24 | Management |
| 20 | 10.2.100.0/24 | Kids |
| 30 | 10.3.100.0/24 | Media/Infrastructure |
| 70 | 10.7.100.0/24 | Guest |
| 90 | 10.9.100.0/24 | IoT |

## Credits

Inspired by and learned from:
- [Sascha Koenig](https://github.com/SaschaKoenig)
- [Alex Kretzschmar](https://github.com/IronicBadger)
- [Vimjoyer](https://www.youtube.com/@vimjoyer)
- And many others in the NixOS community

## License

This configuration is provided as-is for reference. Feel free to use it as inspiration for your own homelab.
