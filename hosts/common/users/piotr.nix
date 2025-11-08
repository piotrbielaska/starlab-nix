{
  config,
  pkgs,
  inputs,
  ...
}: {
  
  users.users.piotr = {
    initialHashedPassword = "$y$j9T$T3VjA6AJldndCmSHSfsHo.$zLXvZj8ZNLxt57Qn37efSvUAANMenGQw0dL1iOlY0/A";
    isNormalUser = true;
    description = "Piotr Bielaska";
    extraGroups = [
      "wheel"
      "networkmanager"
      "podman"
      #"libvirtd"
      #"flatpak"
      #"audio"
      #"video"
      #"plugdev"
      #"input"
      #"kvm"
      #"qemu-libvirtd"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL0Z7v2J3f5SqWVzAjGLwz0qMLddFfFwXjKT7IPi5jmx piotrbielaska@starship"
    ];
    packages = [inputs.home-manager.packages.${pkgs.stdenv.hostPlatform.system}.default];
  };

  home-manager.users.piotr =
    import ../../../home/piotr/${config.networking.hostName}.nix;
  
  programs.git = {
    enable = true;
    config = {
      user = {
        email = "git@bielaska.pl";
        name = "piotr";
      };
      lfs.enable = true;
      init = {
          defaultBranch = "main";
        };
        merge = {
        conflictStyle = "diff3";
          tool = "meld";
        };
        pull = {
          rebase = true;
        };
    };
  };

}

