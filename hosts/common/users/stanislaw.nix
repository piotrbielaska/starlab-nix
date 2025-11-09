{
  config,
  pkgs,
  inputs,
  ...
}: {
  
  users.users.stanislaw = {
    # initialHashedPassword = "";
    isNormalUser = true;
    description = "Stanislaw Bielaska";
    extraGroups = [
      "flatpak"
      "audio"
      "video"
    ];
    openssh.authorizedKeys.keys = [
      #
    ];
    packages = [inputs.home-manager.packages.${pkgs.stdenv.hostPlatform.system}.default];
  };

  home-manager.users.stanislaw =
    import ../../../home/stanislaw/${config.networking.hostName}.nix;

}

