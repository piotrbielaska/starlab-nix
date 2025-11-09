{ 
  config, 
  lib, 
  pkgs, 
  ... 
}: 
with lib; let
  cfg = config.features.desktop.hyprland;
  in {
    options.features.desktop.hyprland.enable = mkEnableOption "Hyprland desktop environment enhancements and integrations";

    config = mkIf cfg.enable {
      programs.hyprland = {
        enable = true;
      };
    };
  }