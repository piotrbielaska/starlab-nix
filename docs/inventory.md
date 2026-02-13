# Hardware Inventory

Complete inventory of StarLAB infrastructure.

## Network Infrastructure

### Sol - Router
| Attribute | Value |
|-----------|-------|
| Model | Ubiquiti Dream Machine Pro SE |
| Role | Main router, firewall, VPN server |
| Location | Rack cabinet (Pomieszczenie Gospodarcze) |
| IP | 10.1.100.1 |
| Power | ~25W |
| Features | 10G SFP+, PoE, IDS/IPS |

### Neptune - Switch
| Attribute | Value |
|-----------|-------|
| Model | Ubiquiti US-8-60W PoE Switch |
| Role | PoE switch for rack devices |
| Location | Rack cabinet |
| Power | ~10-15W (depending on PoE load) |

### WiFi Access Points

| Name | Model | Location | Features |
|------|-------|----------|----------|
| Venus | UniFi UX AP | TBD | WiFi 6 |
| Saturn | UniFi U7 Pro | TBD | WiFi 7 |
| Uranus | UniFi U7 In-Wall | TBD | WiFi 7, In-Wall |

---

## Network Topology

### VLANs

| Network | VLAN | Subnet | Gateway | Purpose |
|---------|------|--------|---------|---------|
| Default | - | 10.1.100.0/24 | 10.1.100.1 | Management (UDM, APs, switches) |
| Dzieci | 20 | 10.2.100.0/24 | 10.2.100.1 | Kids devices |
| Media | 30 | 10.3.100.0/24 | 10.3.100.1 | Moon NAS, Proxmox, media |
| Goście | 70 | 10.7.100.0/24 | 10.7.100.1 | Guest network |
| WorkDev | 80 | 10.8.100.0/24 | 10.8.100.1 | Work/Dev (isolated) |
| IoT | 90 | 10.9.100.0/24 | 10.9.100.1 | Home Assistant, sensors |

### WAN Configuration

| Interface | Provider | Purpose |
|-----------|----------|---------|
| WAN1 | Netia | Primary connection |
| WAN2 | Netia | Failover connection |

**VPN Tunnels:**
- 3x ProtonVPN WireGuard tunnels
- Policy-based routing for privacy

### Traffic Routes

| Route | Target | Devices | Status |
|-------|--------|---------|--------|
| MOON | Internet via VPN | Moon NAS | Enabled (kill switch on) |
| Proton VPN Croatia 4 IoT | Internet via VPN | IoT VLAN | Disabled |

### Static IP Assignments

| Device | Hostname | VLAN | IP Address | MAC |
|--------|----------|------|------------|-----|
| Sol | sol.local | - | 10.1.100.1 | - |
| Moon | moon.local | Media (30) | 10.3.100.100 | TBD |
| Mars | mars.local | Media (30) | 10.3.100.101 | TBD |
| Home Assistant | ha.local | IoT (90) | 10.9.100.100 | TBD |
| Rust VM | rust.local | Media (30) | 10.3.100.102 | TBD |

---

## Servers

### Moon - NAS
| Attribute | Value |
|-----------|-------|
| Model | Synology DS1522+ |
| CPU | AMD Ryzen R1600 (2C/4T) |
| RAM | 8GB DDR4 ECC (expandable to 32GB) |
| Storage | 3x 8TB HDD (Volume 1), 2x 1TB NVMe SSD (Volume 2) |
| Role | Primary storage, Docker host, media server |
| Location | Rack cabinet |
| IP | 10.3.100.100 (Media VLAN) |
| Power | ~40-50W active, ~25W HDD hibernation |
| OS | DSM 7.x |
| Tailscale | ✓ Installed |

**Volume Configuration:**
- Volume 1 (HDD): Data storage, media, backups
- Volume 2 (SSD): Docker containers, databases, cache

**Key Services:** Jellyfin, Immich, Vaultwarden, Arr stack, media automation

**Docker Container Count:** ~44 containers across multiple stacks

### Mars - Proxmox Server (→ NixOS Migration Planned)
| Attribute | Value |
|-----------|-------|
| Model | Dell Optiplex 3060 Micro |
| CPU | Intel Core i3-6100T (2C/4T, 35W TDP) |
| RAM | 16 GB DDR3 (2x 8GB @ 1600 MT/s) |
| Storage | 112GB Patriot Burst SSD |
| Role | Virtualization host → Native NixOS |
| Location | Rack cabinet |
| IP | 10.3.100.101 (Media VLAN) |
| Tailscale | proxmox.little-wyrm.ts.net |
| Power | ~20-30W (optimized) |
| OS | Proxmox VE 8.x → NixOS (planned) |

**Power Optimizations Applied:**
- CPU Governor: `powersave` via systemd service
- PCIe ASPM: `pcie_aspm=force` in GRUB
- Intel P-State driver with dynamic scaling (800 MHz - 3.2 GHz)

**Current Virtual Machines & Containers:**

| ID | Name | Type | Status | CPU | RAM | Storage | Purpose |
|----|------|------|--------|-----|-----|---------|---------|
| 101 | home-assistant | VM | Running | 4 cores | 11.5 GB | 32 GB | Smart home (HAOS 17.0) |
| 102 | docker-lxc | LXC | Running | 2 cores | 2 GB | 8 GB | Docker services |
| 401 | rust | VM | Running | - | 8 GB | 48 GB | NixOS playground |

**Performance Issues (Current):**
- CPU: 90% used, load 3.0 on 4 threads (overloaded)
- RAM: 13GB/15GB used (over-allocated: 21.5GB total)
- Home Assistant VM alone: 169% CPU, 9.7GB RAM

**Planned Migration:** Proxmox → Native NixOS with libvirt for HAOS VM

**Home Assistant USB Devices:**
- Zigbee coordinator (ASUS)
- Bluetooth adapter (Intel)
- RTL-SDR dongle
- Serial adapter (Silicon Labs)

### Jupiter - Desktop
| Attribute | Value |
|-----------|-------|
| Model | H1 Custom Build |
| CPU | AMD Ryzen (model TBD) |
| GPU | AMD Radeon RX 7500 XT |
| RAM | TBD |
| Role | Gaming, transcoding (occasional use) |
| Location | Kids room |
| Power | ~100-300W (high, only used occasionally) |
| OS | Ubuntu → NixOS (planned) |

**Note:** Power hungry - only run when needed for gaming.

---

## Workstations

### Starship - Main Laptop
| Attribute | Value |
|-----------|-------|
| Model | MacBook Pro 14" (2021) |
| CPU | Apple M1 Pro |
| RAM | TBD GB |
| Storage | TBD |
| Role | Primary workstation, development |
| Power | ~15-30W |
| OS | macOS with nix-darwin |
| Tailscale | ✓ Installed |

---

## IoT & Media Devices

### Neso - Apple TV
| Attribute | Value |
|-----------|-------|
| Model | Apple TV 4K (Gen 2) |
| Role | Living room media player |
| Location | Salon |
| Power | ~5W |

### Shuttle - Gaming Console
| Attribute | Value |
|-----------|-------|
| Model | Steam Deck OLED |
| Role | Portable gaming |
| Power | ~15-45W (when docked) |

### Mercury - IoT Gateway
| Attribute | Value |
|-----------|-------|
| Model | Raspberry Pi Zero W |
| Role | wmbusmeters (utility meter reading) |
| Power | ~1W |

### Phobos & Naiad - Zigbee Controllers
| Attribute | Value |
|-----------|-------|
| Model | SMLight Ethernet Zigbee Coordinators |
| Role | Zigbee mesh controllers |
| Power | ~2W each (PoE) |

---

## Tailscale Mesh Network

| Device | Tailscale Name | Status |
|--------|----------------|--------|
| Starship | starship | ✓ Active |
| Moon | moon | ✓ Active |
| Mars/Proxmox | proxmox.little-wyrm.ts.net | ✓ Active |
| Home Assistant | homeassistant | ✓ Active |
| docker-lxc | docker-lxc | ✓ Active |
| Mobile devices | Various | ✓ Active |

**Features Enabled:**
- MagicDNS
- Exit Node (Moon)
- Subnet Router (Moon - home network access)

---

## Power Summary

| Device | Power (W) | 24/7 | Monthly kWh | Monthly Cost |
|--------|-----------|------|-------------|--------------|
| Sol (Router) | 25 | Yes | 18 | ~17 zł |
| Neptune (Switch) | 12 | Yes | 9 | ~9 zł |
| Moon (NAS) | 45 | Yes | 32 | ~31 zł |
| Mars (Proxmox) | 30 | Yes | 22 | ~21 zł |
| **Rack Total** | **~112** | Yes | **~81** | **~78 zł** |
| Jupiter (Desktop) | 200 | No | ~10* | ~10 zł |
| Starship (Laptop) | 20 | Partial | ~5 | ~5 zł |

*Jupiter estimated at ~1.5 hours/day average usage

**Actual Monitoring:** `sensor.pomieszczenie_gospodarcze_szafa_rack_power`

---

## Maintenance Schedule

| Task | Frequency | Last Done | Notes |
|------|-----------|-----------|-------|
| DSM updates | Monthly | TBD | Check Synology for updates |
| Proxmox updates | Monthly | TBD | Backup VMs first |
| SMART tests | Weekly | Automated | Check NAS Health |
| Backup verification | Monthly | TBD | Test restore |
| UPS battery test | Yearly | TBD | If UPS installed |
| NixOS updates | Weekly | TBD | `colmena apply` |

---

## Purchase History

| Device | Purchase Date | Warranty Until |
|--------|---------------|----------------|
| Moon (DS1522+) | TBD | TBD |
| Mars (Optiplex) | TBD | TBD |
| Sol (UDM Pro SE) | TBD | TBD |
