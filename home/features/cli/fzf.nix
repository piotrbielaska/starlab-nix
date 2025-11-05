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
        # tmux.enableShellIntegration = true;

        colors = {
          "fg" = "#f8f8f2";
          "bg" = "#282a36"; 
          "hl" = "#bd93f9";
          "fg+ " = "#f8f8f2";
          "bg+ " = "#44475a";
          "hl+ " = "#bd93f9";
          "info" = "#ffb86c";
          "prompt" = "#50fa7b";
          "pointer" = "#ff79c6";
          "marker" = "#ff79c6";
          "spinner" = "#ffb86c";
          "header" = "#6272a4";
        };

        defaultOptions = [
          "--no-mouse"
          "--preview 'bat --style=numbers --color=always -n {}'"
          "--bind 'ctrl-/:toggle-preview'"
        ];
        defaultCommand = "fd --type f --hidden --follow --exclude .git";
        changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
      };
    };
  }