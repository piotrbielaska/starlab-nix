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
  
    colmena = {
      url = "github:zhaofengli/colmena";
    };

    # sops-nix = { # use to manage secrets (alternative to age-nix)
    #   url = "github:Mic92/sops-nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    agenix = { # use to manage secrets
      url = "github:ryantm/agenix";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dotfiles = {
      url = "github:piotrbielaska/dotfiles";
      flake = false;
    };

  };

  outputs = {
    self,
    agenix,
    disko,
    colmena,
    home-manager,
    nixpkgs,
    nixpkgs-stable,
    dotfiles,
    ...
  } @ inputs: let
    inherit (self) outputs;
    systems = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
    ];
    stateVersion = "25.05"; #nixpkgs-stable release version
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    packages =
      forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    overlays = import ./overlays {inherit inputs;};

    # find how to remove colmena warning about unknown flake output
    # colmenaHive = colmena.lib.makeHive self.outputs.colmena;
    
    colmena = { # use to simplify deployment to remote hosts
      meta = {
        nixpkgs = import nixpkgs {
          system = "x86_64-linux";
        };
        specialArgs = { 
          inherit inputs outputs stateVersion;
        };
        nodeNixpkgs = {
          starship = import nixpkgs-stable {
            system = "aarch64-darwin";
          };
          # mercury = import nixpkgs-stable {
          #   system = "aarch64-linux";
          # };
          # shuttle = import nixpkgs-stable {
          #   system = "aarch64-linux";
          # };
        };
      };
      rust = {
        deployment = {
          buildOnTarget = true; # if you want it to build config on target host
          targetHost = "rust";
          targetUser = "piotr";
          tags = [ "linux" "vm" ];
        };
        imports = [
          ./hosts/rust
          inputs.disko.nixosModules.disko
          agenix.nixosModules.default
        ];
      };
      starship = {
        deployment = {
          allowLocalDeployment = true;
          targetHost = null; # local deploy only with colmena apply-local
          targetUser = "piotr";
          tags = [ "macos" ];
        };
        imports = [
          ./hosts/starship
          agenix.nixosModules.default
        ];
      };
    };

    nixosConfigurations = {
      rust = nixpkgs.lib.nixosSystem {
	      specialArgs = { 
          inherit inputs outputs stateVersion;
        };
	      modules = [
          ./hosts/rust
          inputs.disko.nixosModules.disko
          agenix.nixosModules.default
        ];
      };
    };

    darwinConfigurations = {
      starship = nixpkgs.lib.nixosSystem {
        specialArgs = { 
          inherit inputs outputs stateVersion;
        };
        modules = [
          ./hosts/starship
          agenix.nixosModules.default
        ];
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

      "piotr@starship" = home-manager.lib.homeManagerConfiguration {
      	  pkgs = nixpkgs.legacyPackages."aarch64-darwin";
      	  extraSpecialArgs = {inherit inputs outputs;};
      	  modules = [./home/piotr/starship.nix];
        backupFileExtension = "backup";
      };

      # "krzysztof@starship" = home-manager.lib.homeManagerConfiguration {
      #	  pkgs = nixpkgs.legacyPackages."aarch64-darwin";
      #	  extraSpecialArgs = {inherit inputs outputs;};
      #	  modules = [./home/krzysztof/starship.nix];
      #   backupFileExtension = "backup";
      #};

      # "jagoda@starship" = home-manager.lib.homeManagerConfiguration {
      #	  pkgs = nixpkgs.legacyPackages."aarch64-darwin";
      #	  extraSpecialArgs = {inherit inputs outputs;};
      #	  modules = [./home/jagoda/starship.nix];
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

      # "krzysztof@shuttle" = home-manager.lib.homeManagerConfiguration {
      #	  pkgs = nixpkgs.legacyPackages."aarch64-linux";
      #	  extraSpecialArgs = {inherit inputs outputs;};
      #	  modules = [./home/krzysztof/shuttle.nix];
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
