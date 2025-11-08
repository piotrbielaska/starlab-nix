{ config, pkgs, ... }: { 
  imports = [
    ./home.nix 
    ../common
    ../features/cli
    # ../features/desktop
    # ../features/games
    # ../features/docker
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
    # desktop = {
    #   wayland.enable = true;
    # };
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

