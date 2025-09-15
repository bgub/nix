{
  description = "My system configuration";
  inputs = {
    # monorepo w/ recipes ("derivations")
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # manages configs
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # system-level software and settings (macOS)
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    # declarative homebrew management
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    # declarative flatpak management (pin stable release)
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.6.0";

  };

  outputs =
    {
      self,
      darwin,
      nixpkgs,
      home-manager,
      nix-homebrew,
      nix-flatpak,
      ...
    }@inputs:
    let
      username = "bgub";
    in
    {
      # build darwin flake using:
      # $ darwin-rebuild build --flake .#<name>
      darwinConfigurations."work-macbook" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./darwin
          ./hosts/work-macbook/configuration.nix
        ];
        specialArgs = { inherit inputs self username; };
      };

      # Linux home-manager configuration (Fedora or other non-NixOS Linux)
      # switch with:
      # $ nix run home-manager/master -- switch --flake .#${username}
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        modules = [
          inputs.nix-flatpak.homeManagerModules.nix-flatpak
          ./home
          ./linux
        ];
        extraSpecialArgs = { inherit inputs self username; };
      };

    };
}
