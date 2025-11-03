{
  description = ''
    I like to play with my different machines, OSes with a final result being a production enviroment with services used by me, my family and my friends. I have limited time and very often I have stoped creating a service or setting up a machine in a between home/work activities. Result was that I forgot what I have done. When something broke and I had to rebuild it I have to learn once again. NixOS is a remedium for this. I plan to create a configuration for each machine with applications and services which I can restore easily in a future.

    My LAB is called StarLAB as all devices and VMs are using names from Solar System or farther space.
  '';

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05"; # change version to variable availabe in all files
  };

  outputs = {
    self,
    home-manager,
    nixpkgs,
    ...
  } @ inputs let
    inherit (self) outputs;
    systems = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
    ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    packages =
      forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    overlays = import ./overlays {inherit inputs;};
    nixosConfigurations = {
      rust = nixpkgs.lib.nixosSystem {
	specialArgs = { inherit inputs outputs;};
	modules = [./hosts/rust];
      };
    };
    homeConfigurations = {
      "piotr@rust" = home-manager.lib.homeManagerConfiguration {
	pkgs = nixpkgs.legacyPackages."x86_64-linux";
	extraSpecialArgs = {inherit inputs outputs;};
	modules = [./home/piotr/rust.nix];
      };
    };
  };
}
