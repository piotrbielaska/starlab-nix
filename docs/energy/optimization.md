# Energy Optimization Guide

Power saving settings for StarLAB infrastructure.

## Current Baseline

**Rack Cabinet Power:** 110-123W (measured via `sensor.pomieszczenie_gospodarcze_szafa_rack_power`)

| Device | Est. Power | Notes |
|--------|-----------|-------|
| Synology DS1522+ | 40-50W | HDDs spinning |
| Dell Optiplex 3060 | 25-35W | Proxmox + 2 VMs |
| UDM Pro SE | 25W | Always on |
| UniFi Switch | 10-15W | PoE dependent |

**Target:** Reduce to <100W average

---

## Synology DS1522+ (Moon) Settings

### 1. HDD Hibernation

**Location:** Control Panel → Hardware & Power → HDD Hibernation

```
Recommended Settings:
├── Internal HDD hibernation: 20 minutes
├── External HDD hibernation: 10 minutes
└── Enable HDD hibernation: ON
```

**Expected savings:** 5-10W when all HDDs are spun down

**Note:** SSD cache volume keeps containers responsive while HDDs sleep.

### 2. Power Schedule

**Location:** Control Panel → Hardware & Power → Power Schedule

For 24/7 operation with reduced activity overnight:
- No scheduled shutdown (services needed)
- Use Task Scheduler to shift heavy tasks to off-peak hours

### 3. Task Scheduler

**Location:** Control Panel → Task Scheduler

Reschedule resource-intensive tasks to cheap electricity hours (22:00-06:00):

| Task | Current | Recommended | Type |
|------|---------|-------------|------|
| Hyper Backup | TBD | 02:00 | User-defined script |
| SMART Quick Test | TBD | 05:00 | Built-in |
| SMART Extended Test | TBD | 03:00 (weekly) | Built-in |
| Recycle Bin cleanup | TBD | 04:00 | Built-in |

### 4. Docker Container Optimization

**Location:** Container Manager / docker-compose files

Review containers in `starlab-manual/moon/docker/`:

**Always Running (Essential):**
- Jellyfin (media access)
- Immich (photo backup)
- Vaultwarden (passwords)
- Arr stack (automation)
- Watchtower (updates)

**Can Stop When Unused:**
- Stirling-PDF
- LanguageTool
- Morphos

**Consider Consolidation:**
- Multiple PostgreSQL → single shared instance
- Multiple Redis → single shared instance

To stop optional containers:
```bash
# SSH to NAS
docker stop stirling-pdf languagetool morphos
```

### 5. Network Services

**Location:** Control Panel → File Services / Network

Disable unused services:
- [ ] AFP (if no Mac file sharing needed)
- [ ] NFS (if not used)
- [ ] FTP (if not used)
- [ ] Telnet (security risk anyway)

**Location:** Control Panel → Terminal & SNMP
- [ ] Disable SNMP if not monitoring

### 6. SSD Cache

**Location:** Storage Manager → SSD Cache

Ensure SSD cache is optimized:
- Read-write cache enabled
- Disable excessive logging if not needed

---

## Dell Optiplex 3060 (Mars/Proxmox) Settings

**Hardware:** Intel Core i3-6100T (2C/4T, 35W TDP), 16GB DDR3, 112GB SSD

### Applied Optimizations (2026-01-31)

The following optimizations have been applied and are active:

#### 1. CPU Governor: `powersave` ✓

The system uses the `intel_pstate` driver which only supports `performance` and `powersave` governors.
With intel_pstate, `powersave` allows dynamic frequency scaling (800 MHz - 3.2 GHz) based on load.

**Systemd service:** `/etc/systemd/system/cpu-powersave.service`
```ini
[Unit]
Description=Set CPU governor to powersave
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c "echo powersave | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor"
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

**Verify:**
```bash
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor  # Should show: powersave
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq  # Should show ~800000-2700000
```

#### 2. PCIe ASPM: `pcie_aspm=force` ✓

**GRUB config:** `/etc/default/grub`
```
GRUB_CMDLINE_LINUX_DEFAULT="quiet pcie_aspm=force"
```

**Verify:**
```bash
cat /proc/cmdline | grep pcie_aspm  # Should show: pcie_aspm=force
```

### BIOS Settings (Recommended - Requires Physical Access)

Press F2 during boot to enter BIOS.

#### Power Management
```
BIOS → Power Management:
├── AC Recovery: Power Off (or Last State)
├── Deep Sleep Control: Enabled
├── USB Wake Support: Disabled (unless needed)
├── Wake on LAN: Enabled (for remote wake)
└── Block Sleep: Disabled
```

#### CPU Configuration
```
BIOS → Performance:
├── Intel SpeedStep: Enabled
├── C-States Control: Enabled
├── Intel Turbo Boost: Disabled (optional, saves 5-10W peak)
└── CPU Power Management: OS Control
```

### Current VM/Container Configuration

| ID | Name | Type | CPU | RAM | Notes |
|----|------|------|-----|-----|-------|
| 101 | home-assistant | VM | 4 cores | 11.5 GB | High RAM due to many add-ons |
| 102 | docker-lxc | LXC | 2 cores | 2 GB | Efficient containerized workloads |
| 401 | rust | VM | - | 8 GB | Stopped (playground for NixOS testing) |

#### VM Resource Optimization Notes

**Home Assistant (VM 101):**
- Uses ~11.5 GB RAM due to many add-ons
- Memory ballooning not effective with HAOS
- All 4 CPU threads allocated (required for USB passthrough stability)

**docker-lxc (LXC 102):**
- Efficient alternative to full VMs for Docker workloads
- Nesting enabled for Docker-in-LXC
- Only 2 GB RAM allocated

**Rust (VM 401):**
- Currently stopped (playground for Authentik, Dawarich testing)
- Start only when needed to save resources

### Rust VM (NixOS) Settings

When the Rust VM is running, add to NixOS configuration (`hosts/rust/default.nix`):

```nix
# Power Management
powerManagement = {
  enable = true;
  cpuFreqGovernor = "ondemand";
};

# TLP for advanced power management
services.tlp = {
  enable = true;
  settings = {
    CPU_SCALING_GOVERNOR_ON_AC = "ondemand";
    CPU_ENERGY_PERF_POLICY_ON_AC = "balance_power";
    RUNTIME_PM_ON_AC = "auto";
    PCIE_ASPM_ON_AC = "powersave";
  };
};

# Required package
environment.systemPackages = with pkgs; [
  powertop
];
```

After adding, rebuild:
```bash
# From starship (macOS)
colmena apply --on rust

# Or from rust VM directly
sudo nixos-rebuild switch
```

---

## Monitoring & Verification

### Home Assistant Entities

Monitor these sensors to track improvements:

| Entity | Purpose |
|--------|---------|
| `sensor.pomieszczenie_gospodarcze_szafa_rack_power` | Real-time rack power |
| `sensor.pomieszczenie_gospodarcze_szafa_rack_energy` | Cumulative energy |

### Creating a Tracking Dashboard

Add a simple energy card to track daily/weekly trends.

### Expected Savings

| Optimization | Est. Savings | Status |
|--------------|--------------|--------|
| NAS HDD hibernation | 5-10W | ✓ Applied |
| NAS homes folder on SSD | 2-5W | ✓ Applied (reduces HDD wake) |
| Dell CPU governor (powersave) | 3-5W | ✓ Applied (2026-01-31) |
| Dell PCIe ASPM | 1-2W | ✓ Applied (2026-01-31) |
| Dell BIOS C-states | 2-3W | Pending (requires physical access) |
| **Total Applied** | **~11-22W** | |

**Monthly Impact:**
- 15W reduction × 24h × 30d = 10.8 kWh
- At 0.97 zł/kWh = ~10.5 zł/month savings

**Observed Results:**
- Before optimization: CPU running at constant 3.2 GHz (performance governor)
- After optimization: CPU scales dynamically, idle at ~2.7 GHz or lower

---

## Measurement Procedure

### Before Optimization
1. Note current average from `sensor.pomieszczenie_gospodarcze_szafa_rack_power`
2. Record `sensor.pomieszczenie_gospodarcze_szafa_rack_energy` value
3. Wait 1 week

### After Optimization
1. Apply all settings
2. Wait 1 week for stabilization
3. Compare power averages
4. Calculate actual energy difference

### Recording Results

| Date | Change Made | Before (W) | After (W) | Savings |
|------|-------------|------------|-----------|---------|
| 2026-01 | NAS HDD hibernation (20 min) | TBD | TBD | TBD |
| 2026-01 | NAS homes folder moved to SSD | TBD | TBD | TBD |
| 2026-01-31 | Dell CPU governor (powersave) | TBD | TBD | TBD |
| 2026-01-31 | Dell PCIe ASPM enabled | TBD | TBD | TBD |

**Note:** Monitor `sensor.pomieszczenie_gospodarcze_szafa_rack_power` over the coming weeks to measure actual savings.

---

## Troubleshooting

### HDDs Not Hibernating
- Check for processes accessing volumes: `lsof /volume1`
- Docker containers may prevent hibernation
- Some apps have background scanning

### High CPU Even at Idle
- Check for runaway containers: `docker stats`
- Check Proxmox for VM issues
- Review powertop output: `powertop --html=report.html`

### Services Slow After Power Settings
- Increase HDD hibernation timeout
- Change governor to `ondemand` instead of `powersave`
- Ensure SSD cache is working properly
