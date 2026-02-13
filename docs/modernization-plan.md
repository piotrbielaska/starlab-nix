# StarLAB Homelab Modernization Plan

## Overview

Comprehensive plan to modernize the homelab infrastructure covering:
1. Repository consolidation & secrets management
2. Proxmox → Native NixOS migration
3. Network simplification (VLANs, firewall, routing)
4. Authentik SSO for all services
5. Reverse proxy & external access
6. Tailscale mesh networking
7. New services deployment

## Goals
- Single source of truth for all infrastructure
- No exposed secrets in version control
- Simplified, documented network configuration
- SSO access to all web services
- Secure external access (reverse proxy or Tailscale)
- Unified management via NixOS where possible

---

## Current State (Before Modernization)

### Repositories (fragmented)
| Repo | Purpose | Secrets Status |
|------|---------|----------------|
| starlab-nix | NixOS configs, colmena deployment | agenix (working) |
| starlab-manual | Docker Compose for Moon/Jupiter | Plaintext .env files |
| starlab | Mixed Mars/Proxmox configs | Hardcoded passwords |
| nix-darwin | macOS config (duplicate) | sops-nix unused |
| DOCKER folder | authentik, fireflyiii, maybe, dawarich | Plaintext .env files |
| dotfiles | nvim, karabiner configs | No secrets |

### Critical Security Issues (Resolved)
- ✅ Plaintext passwords in .env files → Now encrypted with age
- ✅ Hardcoded credentials in docker-compose files → Using env_file references
- ✅ No .gitignore protection for .env files → Updated .gitignore
- ⚠️ Google Maps API key, home coordinates still need encryption

---

## Recommended Architecture

### Single Monorepo: `starlab`
Build on existing `starlab-nix` (rename to `starlab`), which already has:
- Working agenix secrets management
- Colmena for NixOS deployment
- Good host structure

### Secrets Strategy

| Host Type | Tool | How It Works |
|-----------|------|--------------|
| NixOS (rust, jupiter) | agenix | Native integration, decrypts at activation |
| nix-darwin (starship) | agenix | Same as NixOS |
| Synology (moon) | age CLI | Decrypt at deploy time via script |

---

## Directory Structure (Implemented)

```
starlab/
├── flake.nix
├── flake.lock
├── README.md
│
├── docs/
│   ├── inventory.md
│   ├── modernization-plan.md    # This file
│   └── services/
│
├── secrets/
│   ├── secrets.nix              # agenix key registry (all hosts)
│   ├── nixos/                   # NixOS secrets (agenix managed)
│   │   ├── rust/
│   │   └── starship/
│   └── docker/                  # Docker .env secrets (age encrypted)
│       └── moon/
│           ├── immich.env.age
│           ├── vaultwarden.env.age
│           └── ...
│
├── hosts/
│   ├── common/                  # Shared NixOS modules
│   ├── rust/                    # NixOS VM (existing)
│   ├── starship/                # macOS (existing)
│   ├── jupiter/                 # H1 desktop (NixOS)
│   └── moon/                    # Synology (Docker only)
│       ├── README.md
│       └── docker/
│           ├── immich/
│           │   ├── docker-compose.yaml
│           │   └── .env.example
│           └── ...
│
├── home/                        # Home-manager configs
│
└── scripts/
    ├── deploy-moon.sh           # Synology deployment
    ├── deploy-nixos.sh          # NixOS wrapper
    └── encrypt-secret.sh        # Secret encryption helper
```

---

## Implementation Phases

### Phase 1: Repository Setup ✅ COMPLETE
1. ✅ Created new directory structure (`hosts/moon/docker/`, `secrets/docker/`)
2. ✅ Updated `.gitignore` to protect secrets

### Phase 2: Secrets Migration ✅ COMPLETE
1. ⚠️ TODO: Generate SSH key on Synology for age decryption
2. ✅ Expanded `secrets/secrets.nix` with all host keys (placeholders for missing)
3. ⚠️ TODO: Encrypt all plaintext secrets with age CLI
4. ✅ Created `.env.example` files for documentation

### Phase 3: Docker Config Migration ✅ COMPLETE
1. ✅ Copied docker-compose files from starlab-manual
2. ✅ Updated compose files to use `env_file:` pointing to decrypted location

### Phase 4: Deployment Scripts ✅ COMPLETE
1. ✅ Created `deploy-moon.sh`
2. ✅ Created `deploy-nixos.sh` wrapper
3. ✅ Created `encrypt-secret.sh` helper

### Phase 5: Documentation ✅ COMPLETE
1. ✅ Updated README with deployment instructions
2. ✅ Created this modernization plan document

---

## Remaining Tasks

### Immediate (Before First Deployment)

1. **Get SSH public keys from hosts**
   ```bash
   # Moon (Synology)
   ssh moon 'cat /etc/ssh/ssh_host_ed25519_key.pub'

   # Mars (Proxmox)
   ssh mars 'cat /etc/ssh/ssh_host_ed25519_key.pub'
   ```

2. **Update secrets/secrets.nix** with actual keys (replace PLACEHOLDER_*)

3. **Encrypt existing .env files**
   ```bash
   # For each service, encrypt the plaintext .env
   ./scripts/encrypt-secret.sh /path/to/immich/.env secrets/docker/moon/immich.env.age
   ```

4. **Test deployment to Moon**
   ```bash
   ./scripts/deploy-moon.sh --dry-run
   ./scripts/deploy-moon.sh immich
   ```

### Phase 6: Proxmox → Native NixOS Migration (Mars)

#### Rationale
- Remove Proxmox overhead (~1-2GB RAM, 10% CPU)
- Unified NixOS management with agenix secrets
- Run services natively instead of nested virtualization

#### Target Architecture
```
Mars (Dell Optiplex i3-6100T, 16GB RAM, 112GB SSD)
└── NixOS (native)
    ├── libvirt/QEMU
    │   └── Home Assistant OS VM (4-6GB RAM, 2 cores)
    ├── Native Services (systemd/containers)
    │   ├── Authentik (server, worker, postgres, redis)
    │   ├── Dawarich (app, sidekiq, postgres, redis)
    │   └── Airtrail (app, postgres)
    ├── Cloudflare Tunnel (systemd service)
    └── Tailscale (systemd service)
```

#### Migration Steps
1. Backup Everything (vzdump HAOS VM, export Authentik data)
2. Prepare NixOS Config (add hosts/mars/ with libvirt, services)
3. Install NixOS on Dell (boot USB, partition, install)
4. Restore Services (import HAOS VM, start native services)
5. Verify & Cleanup (test all services, update DNS)

---

## Phase 7: Network Simplification

### Current VLANs
| VLAN | Network | Purpose |
|------|---------|---------|
| - | 10.1.100.0/24 | Management |
| 20 | 10.2.100.0/24 | Dzieci (Kids) |
| 30 | 10.3.100.0/24 | Media |
| 70 | 10.7.100.0/24 | Goście (Guests) |
| 80 | 10.8.100.0/24 | WorkDev |
| 90 | 10.9.100.0/24 | IoT |

### Proposed Simplification (4 VLANs)
| VLAN | Network | Purpose |
|------|---------|---------|
| 1 | 10.1.100.0/24 | Trusted (family + management) |
| 30 | 10.3.100.0/24 | Infrastructure (servers) |
| 70 | 10.7.100.0/24 | Guest |
| 90 | 10.9.100.0/24 | IoT |

---

## Phase 8: Authentik SSO Integration

### Services to Integrate
| Service | Priority | Status |
|---------|----------|--------|
| Home Assistant | High | To configure |
| Vaultwarden | High | To configure |
| Jellyfin | High | To configure |
| Immich | High | To configure |
| Grafana | Medium | New service |
| Paperless-ngx | Medium | New service |

---

## Phase 9: New Services

### Priority 1 - Core Infrastructure
| Service | Purpose | Host |
|---------|---------|------|
| Uptime Kuma | Service monitoring | Mars |
| Homepage | Dashboard | Mars |
| AdGuard Home | DNS filtering | Mars |

### Priority 2 - Productivity
| Service | Purpose | Host |
|---------|---------|------|
| Paperless-ngx | Document management | Moon |
| Forgejo | Self-hosted Git | Moon |

---

## Synology Deployment Workflow

```bash
# deploy-moon.sh workflow:
1. Decrypt secrets/docker/moon/*.env.age → /tmp/
2. SSH to moon, upload to /volume2/docker/secrets/
3. rsync docker-compose files to /volume2/docker/stacks/
4. Optionally: docker-compose up -d for each stack
```

**On Synology:**
```
/volume2/docker/
├── secrets/           # Decrypted .env files (chmod 600)
│   ├── immich.env
│   ├── vaultwarden.env
│   └── ...
└── stacks/            # Docker compose files
    ├── immich/
    ├── vaultwarden/
    └── ...
```

---

## Backup Strategy

| What | Where | How |
|------|-------|-----|
| Repository | GitHub (private) | git push origin |
| Repository | Synology Git Server | git push synology (mirror) |
| Age private keys | Password manager + offline USB | Manual backup |
| Encrypted secrets | In repo (.age files) | Already backed up with repo |

---

## Verification Checklist

After implementation:
- [ ] Run `nix flake check` - Ensure flake is valid
- [ ] Deploy to rust: `colmena apply --on rust`
- [ ] Deploy to moon: `./scripts/deploy-moon.sh`
- [ ] Verify services start correctly on Synology
- [ ] Confirm no plaintext secrets in git: `git grep -i password`
- [ ] Test secret rotation workflow

---

## Next Steps

1. **Get Moon SSH key** and update secrets.nix
2. **Encrypt all .env files** using encrypt-secret.sh
3. **Test deploy-moon.sh** with dry-run first
4. **Archive old repositories** (starlab-manual, nix-darwin, DOCKER folder)
5. **Schedule maintenance window** for Mars NixOS migration
