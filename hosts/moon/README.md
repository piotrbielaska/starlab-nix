# Moon - Synology DS1522+ NAS

Moon is a Synology DS1522+ NAS running Docker containers for various services.
Since Synology uses its own DSM OS (not NixOS), this host is managed differently:

- Docker Compose files are stored in this directory
- Secrets are encrypted with age and stored in `secrets/docker/moon/`
- Deployment is handled by `scripts/deploy-moon.sh`

## Directory Structure

```
hosts/moon/
├── README.md                 # This file
└── docker/
    ├── immich/               # Photo management
    │   ├── docker-compose.yaml
    │   └── .env.example
    ├── vaultwarden/          # Password manager
    │   ├── docker-compose.yaml
    │   └── .env.example
    ├── media/                # Jellyfin + Arr stack
    │   ├── docker-compose.yaml
    │   └── .env.example
    ├── officeapps/           # Hoarder + productivity tools
    │   ├── docker-compose.yaml
    │   └── .env.example
    ├── actualbudget/         # Budget tracking
    │   ├── docker-compose.yaml
    │   └── .env.example
    ├── authentik/            # SSO (runs on Mars, config here)
    │   ├── docker-compose.yaml
    │   └── .env.example
    ├── notification/         # Notification services
    │   ├── docker-compose.yaml
    │   └── .env.example
    └── karakeep/             # Bookmark manager
        ├── docker-compose.yaml
        └── .env.example
```

## On Synology

The deployment script creates this structure:

```
/volume2/docker/
├── secrets/                  # Decrypted .env files (chmod 600)
│   ├── immich.env
│   ├── vaultwarden.env
│   └── ...
└── stacks/                   # Docker compose files
    ├── immich/
    │   └── docker-compose.yaml
    ├── vaultwarden/
    │   └── docker-compose.yaml
    └── ...
```

## Deployment

```bash
# Deploy all services
./scripts/deploy-moon.sh

# Deploy specific service
./scripts/deploy-moon.sh immich

# Deploy and restart
./scripts/deploy-moon.sh --restart
```

## Hardware Specs

- **Model:** Synology DS1522+
- **CPU:** AMD Ryzen R1600 (dual-core)
- **RAM:** 8GB (upgradeable to 32GB)
- **Storage:** 5-bay NAS (HDD + SSD cache)
- **Network:** 10.3.100.100 (Media VLAN)

## Services Running

| Service | Port | Purpose |
|---------|------|---------|
| Immich | 2283 | Photo management |
| Jellyfin | 8096 | Media streaming |
| Vaultwarden | 8122 | Password manager |
| Sonarr | 8989 | TV show automation |
| Radarr | 7878 | Movie automation |
| Lidarr | 8686 | Music automation |
| Prowlarr | 9696 | Indexer management |
| Audiobookshelf | 13378 | Audiobook streaming |
| Actual Budget | TBD | Budget tracking |
