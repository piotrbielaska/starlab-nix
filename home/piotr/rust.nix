{ config, pkgs, ... }: { 
  imports = [
    ./home.nix
    ./dotfiles
    ../common
    ../features/cli
    ../features/desktop
    # ../features/games
  ]; 

  features = {
    cli = {
      zsh.enable = true;
      fzf.enable = true;
      neofetch.enable = true;
      neovim.enable = true;
      tmux.enable = true;
      starship.enable = true;
    };
    desktop = {
    #   wayland.enable = true;
      fonts.enable = true;
    };
    # games = {
    #   steam.enable = true;
    #   minecraft.enable = true;
    # };
    # docker = {
    #   podman.enable = true; 
    #   docker.enable = true;
    # };
  };

}

