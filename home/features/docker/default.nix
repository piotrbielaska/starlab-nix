{ pkgs, ... }: 
  
{

  imports = [
    ./docker.nix
    ./podman.nix
  ];

  virtualization = {
    podman.enable = true;
    docker.enable = true;
  };

  home.packages = with pkgs; [
    specify packages for home-manager
  ];
}