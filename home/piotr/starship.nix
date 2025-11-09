{ config, pkgs, ... }: { 
  imports = [
    ./home.nix 
    ./dotfiles
    ../common
    ../features/cli
    ../features/games
    ../features/darwin
  ]; 

  features = {
    cli = {
      zsh.enable = true;
      fzf.enable = true;
      neofetch.enable = true;
      neovim.enable = true;
      starship.enable = true;
    };
    desktop = {
      fonts.enable = true;
    };
    games = {
      minecraft.enable = true;
    };
    darwin = {
      common.enable = true;
    };
  };

  ##-----------------------
  ## DOCK PERSISTENT APPS
  ##-----------------------

  system.defaults.dock = {
    persistent-apps = [
      #"/Applications/Arc.app"
      #"/Applications/Signal.app"
      #"/Applications/Fastmail.app"
      #"/Applications/Notion Calendar.app"
      #"/Applications/Bitwarden.app"
      #"/Applications/Warp.app"     
    ];
  };
}