{
  config,
  pkgs,
  inputs,
  ...
}: {
  
  users.users.marianna = {
    # initialHashedPassword = "";
    isNormalUser = true;
    description = "Marianna Bielaska";
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

  home-manager.users.marianna =
    import ../../../home/marianna/${config.networking.hostName}.nix;

}

