{ pkgs, ... }: 
  
{

  imports = [
    ./docker.nix
    ./podman.nix
  ];

  virtualization = {
    podman = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
    docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
  };

  home.packages = with pkgs; [
    specify packages for home-manager
  ];
}