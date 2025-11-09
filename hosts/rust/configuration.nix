# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, stateVersion... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./disko-config.nix
      ./hardware-configuration.nix
      # ./docker/docker.nix # contains list of docker containers settings in separate nix files, which are running as systemclt services using podman
    ];

  # Use the GRUB 2 boot loader.
  # boot.loader.grub.enable = true;
  # boot.loader.grub.device = "/dev/sda";
  # boot.loader.grub.useOSProber = true;
  # moving over to systemd-boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  # boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  ##----------------------------------------------------------
  ## NETWORK  
  ##----------------------------------------------------------

  networking = {
    hostName = "rust";
    wireless = {
      enable = false;
    };
    networkmanager = {
      enable = true; 
    };
  };

  ##----------------------------------------------------------
  ## LOACLES
  ##----------------------------------------------------------
 
  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pl_PL.UTF-8";
    LC_IDENTIFICATION = "pl_PL.UTF-8";
    LC_MEASUREMENT = "pl_PL.UTF-8";
    LC_MONETARY = "pl_PL.UTF-8";
    LC_NAME = "pl_PL.UTF-8";
    LC_NUMERIC = "pl_PL.UTF-8";
    LC_PAPER = "pl_PL.UTF-8";
    LC_TELEPHONE = "pl_PL.UTF-8";
    LC_TIME = "pl_PL.UTF-8";
  };

  # console = {
  #  font = "Lat2-Terminus16";
  #  keyMap = "pl";
  #  useXkbConfig = true; # use xkb.options in tty.
  # };
  #
  # #----------------------------------------------------------
  # # GRAPHICAL INTERFACE
  # #---------------------------------------------------------- 
  #
  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  ##----------------------------------------------------------
  ## USERS
  ##----------------------------------------------------------

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.piotr = {
    isNormalUser = true;
    description = "Piotr Bielaska";
    extraGroups = [ "networkmanager" "wheel" "podman"]; # Enable network modifications, ‘sudo’ for the user and podman controlls
    shell = pkgs.zsh;
    packages = with pkgs; [];
  };

  security = {
    sudo = {
      # wheelNeedsPassword = false; # set to true to require password when using sudo
      extraConfig = "piotr ALL=(ALL) NOPASSWD: ALL"; # allow piotr to use sudo without password
    };
  };

  ##----------------------------------------------------------
  ## PROGRAMS & PACKAGES
  ##----------------------------------------------------------

  nixpkgs.config.allowUnfree = true;

  programs = {
    zsh.enable = true;
    # hyprland = {
    #   enable = false;
    #   xwayland.enable = false;
    # };
  };

  hardware.logitech.wireless.enable = true; # enable Logitech wireless devices support

  environment.systemPackages = with pkgs; [
    neovim
    git
    wget
    curl
    tree
    dive
    podman-tui
    docker-compose
    passt
    bat
    # alacritty ## graphical interface terminal app
    # kitty  ## graphical interface terminal app
    # wofi ## graphical interface launcher
    # warp ## graphical interface terminal app
    # vscode ## graphical interface code editor
  ];

  ##----------------------------------------------------------
  ## FONTS
  ##----------------------------------------------------------

  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono 
    pkgs.nerd-fonts.fira-code
    pkgs.nerd-fonts.fira-mono
    pkgs.nerd-fonts.hack
  ];

  ##----------------------------------------------------------
  ## SERVICES
  ##----------------------------------------------------------

  # Enable the OpenSSH daemon.
  services = {
    openssh = {
      enable = true;
      settings.PermitRootLogin = "no";
      allowSFTP = true;
      # PasswordAuthentication = false; #disable password access via ssh
      # PubkeyAuthentication = true; #enable login using ssh public key
    };
  };

  # Firewall
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = stateVersion; # Did you read the comment?

}

