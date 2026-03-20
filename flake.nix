{
  description = "bgub's system configuration";
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

    cosmic-manager = {
      url = "github:HeitorAugustoLN/cosmic-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # zen browser
    zen-browser.url = "github:youwen5/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";

  };

  outputs =
    {
      self,
      darwin,
      nixpkgs,
      home-manager,
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
        ];
        specialArgs = { inherit inputs self username; };
      };

      darwinConfigurations."mac-mini" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./darwin
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
          inputs.cosmic-manager.homeManagerModules.cosmic-manager
          ./home
          ./linux
          ./home/cosmic.nix
        ];
        extraSpecialArgs = { inherit inputs self username; };
      };

      # NixOS hosts — compose modules per machine
      # switch with: sudo nixos-rebuild switch --flake ~/.config/nix
      nixosConfigurations =
        let
          mkHost =
            {
              hostName,
              extraModules ? [ ],
              stateVersion ? "25.11",
            }:
            nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              modules = [
                {
                  nixpkgs.overlays = [
                    (final: prev: {
                      cosmic-term = prev.cosmic-term.overrideAttrs (old: {
                        patches = (old.patches or [ ]) ++ [
                          (final.fetchpatch {
                            url = "https://github.com/pop-os/cosmic-term/pull/754.patch";
                            hash = "sha256-F1+qoes4URdUstVDp8WYGPaSe/MiEDpAg86Ff3j+NHo=";
                          })
                          (final.fetchpatch {
                            url = "https://github.com/pop-os/cosmic-term/pull/725.patch";
                            hash = "sha256-JsH5UMUub5Xo4gWz3X8TtrRO9F3BCr0SDyr6yIxOJds=";
                          })
                        ];
                      });
                    })
                  ];
                }
                ./nixos/common.nix
                home-manager.nixosModules.home-manager
                {
                  networking.hostName = hostName;
                  system.stateVersion = stateVersion;
                  home-manager.useGlobalPkgs = true;
                  home-manager.useUserPackages = true;
                  home-manager.extraSpecialArgs = { inherit inputs; };
                  home-manager.users.${username} = {
                    imports = [
                      inputs.nix-flatpak.homeManagerModules.nix-flatpak
                      inputs.cosmic-manager.homeManagerModules.cosmic-manager
                      ./home/shell.nix
                      ./home/packages.nix
                      ./home/git.nix
                      ./home/nvim.nix
                      ./home/dotfiles.nix
                      ./home/cosmic.nix
                      ./linux
                    ];
                    home.username = username;
                    home.homeDirectory = "/home/${username}";
                    home.stateVersion = "25.05";
                    programs.home-manager.enable = true;
                  };
                }
              ]
              ++ extraModules;
              specialArgs = { inherit inputs username; };
            };
        in
        {
          xps15 = mkHost {
            hostName = "xps15";
            extraModules = [
              ./nixos/hardware-xps15.nix
              ./nixos/nvidia.nix
            ];
          };

          # to add another host:
          # thinkpad-2 = mkHost {
          #   hostName = "thinkpad-2";
          #   extraModules = [ ./nixos/hardware-thinkpad-2.nix ];
          # };
        };

    };
}
