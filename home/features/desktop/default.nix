{ pkgs, ... }: 
  
{

  imports = [
    ./wayland.nix
  ];

  # specify programs to be installed system-wide

  home.packages = with pkgs; [
    specify packages for home-manager
  ];
}