{
  config,
  pkgs,
  inputs,
  ...
}: {
  
  users.users.krzysztof = {
    # initialHashedPassword = "";
    isNormalUser = true;
    description = "Krzysztof Bielaska";
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

  home-manager.users.krzysztof =
    import ../../../home/krzysztof/${config.networking.hostName}.nix;

}

