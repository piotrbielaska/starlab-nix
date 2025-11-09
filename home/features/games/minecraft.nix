{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.minecraft;
  in {
    options.features.cli.minecraft.enable = mkEnableOption "Minecraft enhancements and integrations";
    config = mkIf cfg.enable {
      home.packages = with pkgs; [
        minecraft
        pakku # minecraft mods manager with versioning
      ];
    };
  }