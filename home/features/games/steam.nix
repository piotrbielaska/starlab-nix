{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.steam;
  in {
    options.features.cli.steam.enable = mkEnableOption "Steam enhancements and integrations";
    config = mkIf cfg.enable {
      home.packages = with pkgs; [
        steam 
      ];
    };
  }