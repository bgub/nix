{
  description = "My system configuration";
  inputs = {
    # monorepo w/ recipes called derivations
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # manages configs and links things
    # into your home directory
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # system-level software and settings (macOS)
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      darwin,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    {
      # build darwin flake using:
      # $ darwin-rebuild build --flake .#<name>
      darwinConfigurations."work-macbook" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./hosts/work-macbook/configuration.nix
        ];
        specialArgs = { inherit inputs self; };
      };

    };
}
