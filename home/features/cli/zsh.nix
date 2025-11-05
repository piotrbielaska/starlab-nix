{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.zsh;
  in {
    options.features.cli.zsh.enable = mkEnableOption "Zsh shell enhancements and integrations";

    config = mkIf cfg.enable {
      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        oh-my-zsh.enable = true;
        syntaxHighlighting.enable = true;
        loginExtra = ''
          set -x NIX_PATH nixpkgs=channel:nixos-unstable # set NIX_PATH for nix commands
          set -x NIX_LOG info # set NIX_LOG to info for better logging
          # set -x TERMINAL kitty # set terminal type for kitty
        '';
        shellAliases = {
          ".." =  "cd .."; # go up one directory
          "..." = "cd ../.."; # go up two directories 
          ll = "ls -laF --color=auto"; # long listing format with hidden files and classify
          la = "ls -A --color=auto"; # list all except . and .. 
          ls = "eza"; # modern replacement for ls command   
          ps = "procs"; # alias to custom script 'proces' located in $HOME/.local/bin
          grep = "rg"; # ripgrep instead of grep
          cat = "bat"; # bat instead of cat
          cd = "z"; # zoxide instead of cd
          curl = "httpie"; # httpie instead of curl
          diff = "diff-so-fancy"; # diff-so-fancy instead of diff
      };
    };
  };
}