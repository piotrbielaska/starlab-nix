# Services Overview

Matrix of all services running in StarLAB infrastructure.

> **Source of Truth:** All configurations are now in this repository (`starlab`).
> - Docker configs: `hosts/moon/docker/`
> - NixOS configs: `hosts/rust/`, `hosts/mars/` (planned)
> - Secrets: `secrets/` (encrypted with agenix/age)

## Service Distribution

| Host | Role | OS | Container Runtime | Config Location |
|------|------|-----|-------------------|-----------------|
| Moon (NAS) | Storage-heavy services | DSM 7 | Docker | `hosts/moon/docker/` |
| Mars/Rust (VM) | Compute-heavy services | NixOS | Podman | `hosts/rust/services/` |
| Mars/HAOS (VM) | Home automation | Home Assistant OS | Built-in | External repo |
| Mars (native) | Infrastructure services | NixOS (planned) | Native/Podman | `hosts/mars/` (planned) |

---

## Moon (Synology DS1522+) Services

**Total Containers:** ~44 running
**Config Location:** `hosts/moon/docker/`
**Deployment:** `./scripts/deploy-moon.sh`

### Media Stack (`moon-media` - 18 containers)

| Service | Port | Purpose | Priority | SSO |
|---------|------|---------|----------|-----|
| Jellyfin | 8096 | Media server | High | Planned |
| Audiobookshelf | 13378 | Audiobooks | Medium | Planned |
| Komga | 25600 | Comics/manga | Low | - |
| Stash | 9999 | Adult library | Low | - |
| Pinchflat | 8945 | YouTube downloader | Low | - |

### Media Automation (Arr Stack)

| Service | Port | Purpose | Priority | SSO |
|---------|------|---------|----------|-----|
| Sonarr | 8989 | TV show management | High | Proxy Auth |
| Radarr | 7878 | Movie management | High | Proxy Auth |
| Lidarr | 8686 | Music management | Medium | Proxy Auth |
| Bazarr | 6767 | Subtitles | Medium | Proxy Auth |
| Prowlarr | 9696 | Indexer management | High | Proxy Auth |
| Autobrr | 7474 | Auto-downloading | Medium | Proxy Auth |
| JellySeerr | 5055 | Request management | Medium | Planned |
| Whisparr | 6969 | Adult content | Low | Proxy Auth |
| Bookshelf | 8787 | Books/audiobooks | Medium | Proxy Auth |

### Download Clients

| Service | Port | Purpose | Priority |
|---------|------|---------|----------|
| RDTClient | 6500 | Real-Debrid client | High |
| Nicotine+ | 6565 | Soulseek client | Low |

### Photo Stack (`moon-photo` - 6 containers)

| Service | Port | Purpose | Priority | SSO |
|---------|------|---------|----------|-----|
| Immich Server | 2283 | Photo backup & management | Critical | Planned |
| Immich ML | internal | Machine learning | High | - |
| Immich Postgres | internal | Database | High | - |
| Immich Redis | internal | Cache | High | - |
| Immich Power Tools | 8001 | Bulk operations | Low | - |
| Immich Frame | 8080 | Digital photo frame | Low | - |

### Office/Productivity (`moon-office` - 8 containers)

| Service | Port | Purpose | Priority | SSO |
|---------|------|---------|----------|-----|
| Hoarder | 4444 | Bookmark/link management | Medium | Planned |
| Stirling-PDF | 8999 | PDF tools | Low | - |
| LanguageTool | 8010 | Grammar checking | Low | - |
| Morphos | 8555 | Document conversion | Low | - |
| Meilisearch | internal | Search engine | Medium | - |
| Chrome | internal | Headless browser | Medium | - |
| Obsidian LiveSync | 5984 | Note sync (CouchDB) | Medium | - |
| Memos | 5230 | Quick notes | Medium | - |

### Finance (`moon-money` - 2 containers)

| Service | Port | Purpose | Priority | SSO |
|---------|------|---------|----------|-----|
| Actual Budget | 5006 | Budgeting app | High | Planned |
| ActualTap-py | 5008 | Tap to pay | Medium | - |

### Security (`moon-passwords` - 1 container)

| Service | Port | Purpose | Priority | SSO |
|---------|------|---------|----------|-----|
| Vaultwarden | 8122 | Password manager | Critical | Planned |

### Utilities (`moon-tools`)

| Service | Port | Purpose | Priority |
|---------|------|---------|----------|
| Watchtower | - | Auto-update containers | High |
| Portainer | 9000 | Container management | Medium |
| Cloudflare Tunnel | - | External access | High |

### iCloud Sync (`icloudpd` - 5 containers)

| Service | Purpose |
|---------|---------|
| icloudpd-piotr | Piotr's iCloud sync |
| icloudpd-marianna | Marianna's iCloud sync |
| icloudpd-krzysztof | Krzysztof's iCloud sync |
| icloudpd-jagoda | Jagoda's iCloud sync |
| (shared) | Shared family sync |

---

## Mars (Dell Optiplex 3060 Micro / Proxmox → NixOS)

**Host:** Intel Core i3-6100T, 16GB RAM, 112GB SSD
**Access:** proxmox.little-wyrm.ts.net (Tailscale)
**Config Location:** `hosts/rust/` (current), `hosts/mars/` (planned)

### Current: docker-lxc (LXC 102) - Ubuntu + Docker

**Status:** Running (24/7)
**Resources:** 2 cores, 2GB RAM, 8GB storage
**IP:** 10.9.100.127 (IoT VLAN)

| Service | Port | Purpose | Priority | SSO |
|---------|------|---------|----------|-----|
| Authentik Server | 9000 | SSO/Identity provider | Critical | - |
| Authentik Worker | - | Background tasks | Critical | - |
| Authentik Postgres | - | Database | Critical | - |
| Authentik Redis | - | Cache | Critical | - |

### Current: Home Assistant VM (VM 101) - HAOS 17.0

**Status:** Running (24/7)
**Resources:** 4 cores, 11.5GB RAM, 32GB storage
**IP:** 10.9.100.100 (IoT VLAN)

| Service | Port | Purpose | Priority | SSO |
|---------|------|---------|----------|-----|
| Home Assistant | 8123 | Smart home control | Critical | Planned |
| Add-ons | Various | HA ecosystem | Varies | - |

**USB Devices Passed Through:**
- Zigbee coordinator
- Bluetooth adapter (Intel)
- RTL-SDR dongle
- Serial adapter

### Current: Rust VM (VM 401) - NixOS

**Status:** Running
**Resources:** 8GB RAM, 48GB storage
**Config:** `hosts/rust/`

| Service | Port | Purpose | Priority |
|---------|------|---------|----------|
| Dawarich | TBD | Location tracking | Medium |
| Dawarich Sidekiq | - | Background jobs | Medium |
| Dawarich Postgres | - | Database | Medium |
| Dawarich Redis | - | Cache | Medium |
| Airtrail | TBD | Flight tracking | Medium |
| Airtrail Postgres | - | Database | Medium |

### Planned: Mars (Native NixOS)

After Proxmox → NixOS migration:

| Service | Type | Purpose | Priority |
|---------|------|---------|----------|
| Home Assistant OS | libvirt VM | Smart home | Critical |
| Authentik | Native | SSO | Critical |
| Dawarich | Native | Location tracking | Medium |
| Airtrail | Native | Flight tracking | Medium |
| AdGuard Home | Native | DNS filtering | High |
| Uptime Kuma | Native | Monitoring | High |
| Homepage | Native | Dashboard | Medium |
| Cloudflare Tunnel | systemd | External access | High |
| Tailscale | systemd | Mesh networking | High |

---

## Jupiter (H1 Desktop / Ubuntu → NixOS)

**Config Location:** `hosts/jupiter/` (placeholder)
**Note:** Only runs occasionally (gaming, heavy processing).

| Service | Port | Purpose | Priority |
|---------|------|---------|----------|
| (Gaming) | - | Steam, etc. | - |
| (Transcoding) | - | Future Jellyfin offload | Low |

---

## Service Dependencies

```
Authentik (SSO) - auth.bielaska.cloud
    ├── Home Assistant
    ├── Jellyfin
    ├── Immich
    ├── Vaultwarden
    ├── Actual Budget
    ├── Grafana (planned)
    └── Arr Stack (proxy auth)

PostgreSQL (per-service instances)
    ├── Authentik (dedicated)
    ├── Immich (dedicated)
    ├── Dawarich (dedicated)
    ├── Airtrail (dedicated)
    └── (shared instance planned for Mars)

Redis (per-service instances)
    ├── Authentik (dedicated)
    ├── Immich (dedicated)
    └── Dawarich (dedicated)
```

---

## Critical Services (Must Not Fail)

| Priority | Service | Host | Recovery |
|----------|---------|------|----------|
| 1 | Vaultwarden | Moon | Local admin fallback |
| 2 | Home Assistant | Mars | USB device passthrough |
| 3 | Immich | Moon | Daily DB backup |
| 4 | Authentik | Mars | Local admin accounts |

---

## External Access

### Cloudflare Tunnel (Current)

| Service | Domain | Status |
|---------|--------|--------|
| Home Assistant | ha.bielaska.cloud | Active |
| Authentik | auth.bielaska.cloud | Active |
| Vaultwarden | vault.bielaska.cloud | Planned |
| Immich | photos.bielaska.cloud | Planned |
| Jellyfin | media.bielaska.cloud | Planned |

### Tailscale (Internal)

All services accessible via Tailscale mesh network without exposing to internet.

---

## Backup Priorities

| Priority | Services | Backup Method | Frequency |
|----------|----------|---------------|-----------|
| Critical | Vaultwarden, Immich DB | Offsite (encrypted) | Daily |
| High | HA config, Authentik | Local + Synology | Daily |
| Medium | Arr stack configs, Actual Budget | Synology | Weekly |
| Low | Stirling-PDF, etc. | None (stateless) | - |

---

## Port Summary

| Port Range | Use |
|------------|-----|
| 80, 443 | Cloudflare Tunnel |
| 2283 | Immich |
| 5006 | Actual Budget |
| 5055 | JellySeerr |
| 5984 | Obsidian LiveSync |
| 6500 | RDTClient |
| 6767 | Bazarr |
| 7474 | Autobrr |
| 7878 | Radarr |
| 8001 | Immich Power Tools |
| 8010 | LanguageTool |
| 8080 | Immich Frame |
| 8096 | Jellyfin |
| 8122 | Vaultwarden |
| 8123 | Home Assistant |
| 8686 | Lidarr |
| 8787 | Bookshelf |
| 8945 | Pinchflat |
| 8989 | Sonarr |
| 8999 | Stirling-PDF |
| 9000 | Authentik |
| 9696 | Prowlarr |
| 9999 | Stash |
| 13378 | Audiobookshelf |
| 25600 | Komga |

---

## Planned New Services

### Priority 1 - Core Infrastructure (Mars)

| Service | Purpose | SSO |
|---------|---------|-----|
| Uptime Kuma | Service monitoring & alerts | Yes |
| Homepage | Unified dashboard | No |
| AdGuard Home | DNS filtering & ad blocking | Yes |

### Priority 2 - Productivity (Moon)

| Service | Purpose | SSO |
|---------|---------|-----|
| Paperless-ngx | Document management & OCR | Yes |
| AdventureLog | Travel/adventure tracking | Yes |

### Priority 3 - Development (Moon)

| Service | Purpose | SSO |
|---------|---------|-----|
| Forgejo | Self-hosted Git | Yes |
| Woodpecker CI | CI/CD pipelines | Yes |

### Priority 4 - Future (Mac Mini M4)

| Service | Purpose | SSO |
|---------|---------|-----|
| Ollama | Local LLM inference | API |
| Open WebUI | Ollama web interface | Yes |
