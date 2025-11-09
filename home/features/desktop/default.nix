{ pkgs, ... }: 
  
{

  imports = [
  #  ./wayland.nix
  #  ./hyprland.nix
    ./fonts.nix
  ];

  # specify programs to be installed system-wide

  home.packages = with pkgs; [
      pkgs.solaar # logitech devices manager
  ];
}