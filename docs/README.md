# StarLAB Documentation

Central documentation for the StarLAB homelab infrastructure.

## Quick Links

| Document | Description |
|----------|-------------|
| [Inventory](./inventory.md) | Hardware inventory with specs and network info |
| [Services Overview](./services/overview.md) | What runs where |
| [Energy Optimization](./energy/optimization.md) | Power saving settings |
| [Modernization Plan](./modernization-plan.md) | Infrastructure modernization roadmap |

## Infrastructure Overview

```
                    Internet
                        │
                   ┌────┴────┐
                   │   Sol   │  Ubiquiti Dream Machine Pro SE
                   │ Router  │  10.1.100.1
                   └────┬────┘
                        │
         ┌──────────────┼──────────────┐
         │              │              │
   ┌─────┴─────┐  ┌─────┴─────┐  ┌─────┴─────┐
   │  Neptune  │  │  Starship │  │   WiFi    │
   │  Switch   │  │  MacBook  │  │   APs     │
   └─────┬─────┘  └───────────┘  └───────────┘
         │
    ┌────┼────┬────────┐
    │    │    │        │
┌───┴──┐ │ ┌──┴───┐ ┌──┴──┐
│ Moon │ │ │ Mars │ │ Neso│
│ NAS  │ │ │Proxmox│ │ ATV │
└──────┘ │ └──┬───┘ └─────┘
         │    │
         │  ┌─┴───────┐
         │  │   VMs   │
         │  ├─────────┤
         │  │ HAOS    │
         │  │ docker  │
         │  │ rust    │
         │  └─────────┘
         │
    ┌────┴────┐
    │ Jupiter │
    │ Desktop │
    └─────────┘
```

## Naming Convention

All devices follow a solar system naming theme:

| Name | Type | Description |
|------|------|-------------|
| Sol | Router | Ubiquiti Dream Machine Pro SE |
| Neptune | Switch | Ubiquiti US-8-60W PoE Switch |
| Venus | WiFi AP | UniFi UX AP |
| Saturn | WiFi AP | UniFi U7 Pro |
| Uranus | WiFi AP | UniFi U7 In-Wall |
| Moon | NAS | Synology DS1522+ |
| Mars | Server | Dell Optiplex i3-6100T (Proxmox → NixOS) |
| Jupiter | Desktop | H1 Gaming PC |
| Starship | Laptop | MacBook Pro M1 14" |
| Shuttle | Console | SteamDeck OLED |
| Neso | Media | Apple TV 4K |
| Mercury | IoT | Raspberry Pi Zero W |
| Phobos/Naiad | Zigbee | SMlight Controllers |

## Network Architecture

| Network | VLAN | Subnet | Purpose |
|---------|------|--------|---------|
| Default | - | 10.1.100.0/24 | Management (UDM, APs, switches) |
| Dzieci | 20 | 10.2.100.0/24 | Kids devices |
| Media | 30 | 10.3.100.0/24 | Moon NAS, Proxmox, media |
| Goście | 70 | 10.7.100.0/24 | Guest network |
| WorkDev | 80 | 10.8.100.0/24 | Work/Dev (isolated) |
| IoT | 90 | 10.9.100.0/24 | Home Assistant, sensors |

**WAN:** Dual Netia connections (failover), 3x ProtonVPN WireGuard tunnels

## Repository Structure

This repository (`starlab`) is the **single source of truth** for all infrastructure:

```
starlab/
├── flake.nix                    # Nix flake configuration
├── README.md                    # Main README
│
├── docs/                        # Documentation (you are here)
│   ├── README.md
│   ├── inventory.md             # Hardware inventory
│   ├── modernization-plan.md    # Infrastructure roadmap
│   ├── services/
│   │   └── overview.md          # Service matrix
│   └── energy/
│       └── optimization.md      # Power saving settings
│
├── secrets/
│   ├── secrets.nix              # Agenix key registry
│   ├── nixos/                   # NixOS secrets (agenix managed)
│   └── docker/                  # Docker .env secrets (age encrypted)
│       └── moon/
│
├── hosts/
│   ├── common/                  # Shared NixOS modules
│   ├── rust/                    # NixOS VM config
│   ├── starship/                # macOS (nix-darwin) config
│   ├── jupiter/                 # H1 Desktop config
│   ├── mars/                    # Dell Optiplex config (planned)
│   └── moon/                    # Synology Docker configs
│       ├── README.md
│       └── docker/
│           ├── immich/
│           ├── vaultwarden/
│           ├── media/
│           └── ...
│
├── home/                        # Home-manager configs
│
└── scripts/
    ├── deploy-moon.sh           # Synology deployment
    ├── deploy-nixos.sh          # NixOS deployment wrapper
    └── encrypt-secret.sh        # Secret encryption helper
```

## Secrets Management

All secrets are encrypted using [agenix](https://github.com/ryantm/agenix) (age encryption):

| Host Type | Tool | How It Works |
|-----------|------|--------------|
| NixOS (rust, jupiter, mars) | agenix | Native integration, decrypts at activation |
| nix-darwin (starship) | agenix | Same as NixOS |
| Synology (moon) | age CLI | Decrypt at deploy time via `deploy-moon.sh` |

## Deployment

### NixOS Hosts
```bash
./scripts/deploy-nixos.sh              # All hosts
./scripts/deploy-nixos.sh rust         # Specific host
./scripts/deploy-nixos.sh --check      # Validate only
```

### Synology (Moon)
```bash
./scripts/deploy-moon.sh               # All services
./scripts/deploy-moon.sh immich        # Specific service
./scripts/deploy-moon.sh --restart     # Deploy and restart
```

## Related Repositories

| Repository | Purpose | Status |
|------------|---------|--------|
| `starlab` | NixOS/nix-darwin/Docker configs (this repo) | **Active** |
| `dotfiles` | Shell and application dotfiles | Active (flake input) |
| `home-assistant-dashboards` | HA dashboard configurations | Active |
| `jellyfin-web` | Jellyfin web UI customizations | Active |
| `starlab-manual` | Legacy Docker configs | **Deprecated** → merged here |
| `nix-darwin` | Legacy macOS config | **Deprecated** → merged here |

## Contributing

When adding documentation:
1. Use Markdown format
2. Include diagrams where helpful (use ASCII or Mermaid)
3. Keep sensitive info (passwords, API keys) out of docs
4. Reference actual config files where applicable
5. Update this README when adding new documents
