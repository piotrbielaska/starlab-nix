{
  config,
  pkgs,
  inputs,
  ...
}: {
  
  users.users.jagoda = {
    # initialHashedPassword = "$y$j9T$T3VjA6AJldndCmSHSfsHo.$zLXvZj8ZNLxt57Qn37efSvUAANMenGQw0dL1iOlY0/A";
    isNormalUser = true;
    description = "Jagoda Bielaska";
    extraGroups = [
      #"wheel"
      #"networkmanager"
      #"podman"
      #"libvirtd"
      "flatpak"
      "audio"
      "video"
      #"plugdev"
      #"input"
      #"kvm"
      #"qemu-libvirtd"
    ];
    openssh.authorizedKeys.keys = [
      #
    ];
    packages = [inputs.home-manager.packages.${pkgs.stdenv.hostPlatform.system}.default];
  };

  home-manager.users.jagoda =
    import ../../../home/jagoda/${config.networking.hostName}.nix;

}

