{
  pkgs,
  inputs,
  self,
  ...
}:
{
  imports = [
    ../modules/homebrew-common.nix
    inputs.home-manager.darwinModules.home-manager
  ];

  # home-manager configuration (integrates with nix-darwin)
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.nebrelbug = {
      imports = [
        ./shared.nix
      ];

      # macOS-specific user packages
      home.packages = with pkgs; [

      ];
    };
    extraSpecialArgs = {
      inherit inputs self;
    };
  };

  # macOS-specific settings (system-level)
  nix.enable = false; # using determinate installer
  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config.allowUnfree = true; # Allow unfree packages
  };

  system.primaryUser = "nebrelbug";
  users.users.nebrelbug = {
    home = "/Users/nebrelbug";
    shell = pkgs.zsh;
  };

  environment = {
    systemPath = [
      "/opt/homebrew/bin"
    ];
    pathsToLink = [ "/Applications" ];
  };

  # touch ID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  # system defaults and preferences
  system = {
    stateVersion = 6;
    configurationRevision = self.rev or self.dirtyRev or null;

    startup.chime = false;

    defaults = {
      loginwindow = {
        GuestEnabled = false;
        DisableConsoleAccess = true;
      };

      finder = {
        AppleShowAllFiles = true; # hidden files
        AppleShowAllExtensions = true; # file extensions
        _FXShowPosixPathInTitle = true; # title bar full path
        ShowPathbar = true; # breadcrumb nav at bottom
        ShowStatusBar = true; # file count & disk space
      };

      NSGlobalDomain = {
        NSAutomaticSpellingCorrectionEnabled = false;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticWindowAnimationsEnabled = false;
      };

    };
  };
}
