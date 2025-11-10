{ 
  config,
  lib,
  pkgs,
  ... 
}:
with lib;  let
  cfg = config.extraservices.podman;  
in
{
  options.extraservices.podman.enable = mkEnableOption "Enable Podman containerization service with useful defaults";

  config = mkIf cfg.enable {
   
    # imports = [
    #   ./containers
    # ];

    virtualisation = {
      oci-containers.backend = "podman";
      podman = {
        enable = true;
        dockerCompat = true;
        autoPrune = {
          enable = true;
          dates = "weekly";
          flags = [
            "--filter=until=24h"
            "--filter=label!=important"
          ];
        };
        defaultNetwork = {
          settings = {
            dns_enabled = true;
          };
        };
      };
    };

    environment.systemPackages = with pkgs; [
      podman-compose # docker-compose clone for podman
      podman-tui # terminal user interface for podman
      dive # docker image explorer
    ];

  };
}