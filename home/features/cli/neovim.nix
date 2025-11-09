{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.neovim;
  in {
    options.features.cli.neovim.enable = mkEnableOption "Neovim enhancements and plugins";

    config = mkIf cfg.enable {
      programs.neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;
      };
    };
  }  
