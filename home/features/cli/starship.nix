{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.starship;
  in {
    options.features.cli.starship.enable = mkEnableOption "Starship prompt enhancements and integrations";

    config = mkIf cfg.enable {
      programs.starship = {
        enable = true;
        enableZshIntegration = true;
        enableBashIntegration = true;
        settings = pkgs.lib.importTOML ../features/cli/starship/starship.toml;
      };
    };
  };
}