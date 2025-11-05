{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.fzf;
  in {
    options.features.cli.fzf.enable = mkEnableOption "Fuzzy finder enhancements and integrations";

    config = mkIf cfg.enable {
      programs.fzf = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
        tmux.enableShellIntegration = true;
        defaultOptions = [
          "--no-mouse"
    ];
    };
  };
}