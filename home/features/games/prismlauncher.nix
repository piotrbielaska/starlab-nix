{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.prismlauncher;
  in {
    options.features.cli.minecraft.enable = mkEnableOption "Minecraft enhancements and integrations";
    config = mkIf cfg.enable {
      home.packages = with pkgs; [
        prismlauncher # minecratf launcher with mods
        pakku # minecraft mods manager with versioning
      ];
    };
  }