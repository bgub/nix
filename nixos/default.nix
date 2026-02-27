{
  pkgs,
  inputs,
  self,
  username,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  # nix config
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
    };
  };

  nixpkgs.config.allowUnfree = true;

  # boot — customize after running nixos-generate-config
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # networking
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
  };

  # locale & time
  time.timeZone = "America/Denver";
  i18n.defaultLocale = "en_US.UTF-8";

  # desktop
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;

  # audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # flatpak (system-level support; apps managed via home-manager nix-flatpak)
  services.flatpak.enable = true;

  # user account
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;

  # home-manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${username} = {
      imports = [
        inputs.nix-flatpak.homeManagerModules.nix-flatpak
        ../home
        ../linux
      ];
    };
    extraSpecialArgs = {
      inherit inputs self username;
    };
  };

  system.stateVersion = "25.05";
}
