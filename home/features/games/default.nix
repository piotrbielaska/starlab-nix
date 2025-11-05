{ pkgs, ... }: 
  
{

  imports = [
    ./steam.nix
    ./minecraft.nix
  ];

  # specify programs to be installed system-wide

  home.packages = with pkgs; [
    specify packages for home-manager
  ];
}