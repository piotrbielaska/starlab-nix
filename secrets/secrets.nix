# Agenix secrets configuration
# Each host needs its SSH public key listed here to decrypt secrets assigned to it
#
# To get a host's SSH public key:
#   ssh-keyscan -t ed25519 <hostname> 2>/dev/null | cut -d' ' -f2-
# Or on the host itself:
#   cat /etc/ssh/ssh_host_ed25519_key.pub
#
# For Synology (Moon):
#   ssh moon 'cat /etc/ssh/ssh_host_ed25519_key.pub'
#
# For personal key (used for decryption from any machine):
#   cat ~/.ssh/id_ed25519.pub

let
  # ===================
  # Host SSH Public Keys
  # ===================

  # NixOS VM on Mars (Proxmox) - for Dawarich, Airtrail services
  rust = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEYt29D2ktU4ub5cGHX1ND1xAIPCK8620T8a85lYuzB9";

  # MacBook Pro M1 - nix-darwin managed
  starship = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL0Z7v2J3f5SqWVzAjGLwz0qMLddFfFwXjKT7IPi5jmx piotrbielaska@starship";

  # Synology DS1522+ NAS - Docker host for media services
  # TODO: Get key with: ssh moon 'cat /etc/ssh/ssh_host_ed25519_key.pub'
  moon = "ssh-ed25519 PLACEHOLDER_MOON_KEY";

  # Dell Optiplex i3-6100T - will become native NixOS (currently Proxmox)
  # TODO: Get key after NixOS installation
  mars = "ssh-ed25519 PLACEHOLDER_MARS_KEY";

  # H1 Desktop - gaming/transcoding server
  # TODO: Get key after NixOS installation
  jupiter = "ssh-ed25519 PLACEHOLDER_JUPITER_KEY";

  # ===================
  # User SSH Public Keys
  # ===================

  # Piotr's personal key - can decrypt all secrets for administration
  piotr = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL0Z7v2J3f5SqWVzAjGLwz0qMLddFfFwXjKT7IPi5jmx piotrbielaska@starship";

  # ===================
  # Key Groups
  # ===================

  # All NixOS hosts
  nixosHosts = [ rust mars jupiter ];

  # All hosts including non-NixOS
  allHosts = [ rust starship moon mars jupiter ];

  # Admin users who can decrypt any secret
  admins = [ piotr ];

in {
  # ===================
  # NixOS Secrets (agenix native)
  # ===================

  # Rust VM secrets
  "secret_rust.age".publicKeys = [ rust piotr ];

  # Dawarich location tracking (on rust)
  "nixos/rust/dawarich.age".publicKeys = [ rust piotr ];
  "nixos/rust/dawarich-postgres.age".publicKeys = [ rust piotr ];

  # Airtrail flight tracking (on rust)
  "nixos/rust/airtrail.age".publicKeys = [ rust piotr ];
  "nixos/rust/airtrail-postgres.age".publicKeys = [ rust piotr ];

  # Mars secrets (after NixOS migration)
  "nixos/mars/authentik.age".publicKeys = [ mars piotr ];
  "nixos/mars/authentik-postgres.age".publicKeys = [ mars piotr ];

  # ===================
  # Docker Secrets (age encrypted .env files)
  # These are decrypted by deploy-moon.sh before upload
  # ===================

  # Moon (Synology) - Media services
  "docker/moon/immich.env.age".publicKeys = [ moon piotr ];
  "docker/moon/vaultwarden.env.age".publicKeys = [ moon piotr ];
  "docker/moon/media.env.age".publicKeys = [ moon piotr ];
  "docker/moon/officeapps.env.age".publicKeys = [ moon piotr ];
  "docker/moon/actualbudget.env.age".publicKeys = [ moon piotr ];
  "docker/moon/authentik.env.age".publicKeys = [ moon piotr ];
  "docker/moon/notification.env.age".publicKeys = [ moon piotr ];
  "docker/moon/karakeep.env.age".publicKeys = [ moon piotr ];

  # ===================
  # Starship (macOS) secrets
  # ===================
  "nixos/starship/secrets.age".publicKeys = [ starship piotr ];
}
