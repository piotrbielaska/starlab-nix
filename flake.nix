{
  description = ''
    I like to play with my different machines, OSes with a final result being a production enviroment with services used by me, my family and my friends. I have limited time and very often I have stoped creating a service or setting up a machine in a between home/work activities. Result was that I forgot what I have done. When something broke and I had to rebuild it I have to learn once again. NixOS is a remedium for this. I plan to create a configuration for each machine with applications and services which I can restore easily in a future.

    My LAB is called StarLAB as all devices and VMs are using names from Solar System or beyond.
  '';

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05"; # change version to variable availabe in all files
    
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:lnl7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = { url = "github:homebrew/homebrew-core"; flake = false; };
    homebrew-cask = { url = "github:homebrew/homebrew-cask"; flake = false; };
    homebrew-bundle = { url = "github:homebrew/homebrew-bundle"; flake = false; };
  
    # sops-nix.url = "github:Mic92/sops-nix";
    # sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # disko.url = "github:nix-community/disko";
    # disko.inputs.nixpkgs.follows = "nixpkgs";

  };

  outputs = {
    self,
    home-manager,
    nixpkgs,
    ...
  } @ inputs: let
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
      ## ------------------------------------
      ## RUST | TEST VM & DOCKER HOST @ MARS
      ## ------------------------------------

      "piotr@rust" = home-manager.lib.homeManagerConfiguration {
	      pkgs = nixpkgs.legacyPackages."x86_64-linux";
	      extraSpecialArgs = {inherit inputs outputs;};
	      modules = [./home/piotr/rust.nix];
        backupFileExtension = "backup";
      };

      ## --------------------------------
      ## OXIDE | HOME ASSISTANT VM @ MARS
      ## --------------------------------

      # "piotr@oxide" = home-manager.lib.homeManagerConfiguration {
      #	  pkgs = nixpkgs.legacyPackages."x86_64-linux";
      #	  extraSpecialArgs = {inherit inputs outputs;};
      #	  modules = [./home/piotr/oxide.nix];
      #   backupFileExtension = "backup";
      #};

      ## -------------------------------------------------
      ## JUPITER | H1 DESKTOP GAMING & TRANSCODING SERVER
      ## -------------------------------------------------

      # "piotr@jupiter" = home-manager.lib.homeManagerConfiguration {
      #	  pkgs = nixpkgs.legacyPackages."x86_64-linux";
      #	  extraSpecialArgs = {inherit inputs outputs;};
      #	  modules = [./home/piotr/jupiter.nix];
      #   backupFileExtension = "backup";
      #};
      # "marianna@jupiter" = home-manager.lib.homeManagerConfiguration {
      #	  pkgs = nixpkgs.legacyPackages."x86_64-linux";
      #	  extraSpecialArgs = {inherit inputs outputs;};
      #	  modules = [./home/marianna/jupiter.nix];
      #   backupFileExtension = "backup";
      #};
      # "krzysztof@jupiter" = home-manager.lib.homeManagerConfiguration {
      #	  pkgs = nixpkgs.legacyPackages."x86_64-linux";
      #	  extraSpecialArgs = {inherit inputs outputs;};
      #	  modules = [./home/krzysztof/jupiter.nix];
      #   backupFileExtension = "backup";
      #};      
      # "jagoda@jupiter" = home-manager.lib.homeManagerConfiguration {
      #	  pkgs = nixpkgs.legacyPackages."x86_64-linux";
      #	  extraSpecialArgs = {inherit inputs outputs;};
      #	  modules = [./home/jagoda/jupiter.nix];
      #   backupFileExtension = "backup";
      #};      
      # "stanislaw@jupiter" = home-manager.lib.homeManagerConfiguration {
      #	  pkgs = nixpkgs.legacyPackages."x86_64-linux";
      #	  extraSpecialArgs = {inherit inputs outputs;};
      #	  modules = [./home/stanislaw/jupiter.nix];
      #   backupFileExtension = "backup";
      #};

      ## -----------------------------------------------------
      ## MERCURY | RASPERRY PI ZERO W FOR WMBUSMETERS READING
      ## -----------------------------------------------------

      # "piotr@mercury" = home-manager.lib.homeManagerConfiguration {
      #	  pkgs = nixpkgs.legacyPackages."aarch64-linux";
      #	  extraSpecialArgs = {inherit inputs outputs;};
      #	  modules = [./home/piotr/mercury.nix];
      #   backupFileExtension = "backup";
      #};

      ## ---------------------------------
      ## STARSHIP | MACBOOK PRO 14 PRO M1
      ## ---------------------------------

      # "piotr@starship" = home-manager.lib.homeManagerConfiguration {
      #	  pkgs = nixpkgs.legacyPackages."aarch64-darwin";
      #	  extraSpecialArgs = {inherit inputs outputs;};
      #	  modules = [./home/piotr/starship.nix];
      #   backupFileExtension = "backup";
      #};

      ## --------------------------
      ## SHUTTLE | STEAMDECK OLED
      ## --------------------------

      # "piotr@shuttle" = home-manager.lib.homeManagerConfiguration {
      #	  pkgs = nixpkgs.legacyPackages."aarch64-linux";
      #	  extraSpecialArgs = {inherit inputs outputs;};
      #	  modules = [./home/piotr/shuttle.nix];
      #   backupFileExtension = "backup";
      #};

      ## ----------------------------
      ## MOON | SYNOLOGY DS1522+ NAS
      ## ----------------------------

      # "piotr@moon" = home-manager.lib.homeManagerConfiguration {
      #	  pkgs = nixpkgs.legacyPackages."aarch64-linux";
      #	  extraSpecialArgs = {inherit inputs outputs;};
      #	  modules = [./home/piotr/moon.nix];
      #   backupFileExtension = "backup";
      #};

      ## -----------------------------------------------------------------------------------------------------------
      ## EARTH | DYI NAS (FUTURE BUILD TO REPLACE MOON AND JUPITER FOR TRANSCODING AND MEMORY/POWER HUNGRY SERVICES)
      ## -----------------------------------------------------------------------------------------------------------    

      # "piotr@earth" = home-manager.lib.homeManagerConfiguration {
      #	  pkgs = nixpkgs.legacyPackages."x86_64-linux";
      #	  extraSpecialArgs = {inherit inputs outputs;};
      #	  modules = [./home/piotr/earth.nix];
      #   backupFileExtension = "backup";
      #};


    };
  };
}
