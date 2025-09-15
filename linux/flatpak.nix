{ ... }:
{
  # nix-flatpak Home Manager module must be imported by the caller (flake does it)
  services.flatpak = {
    enable = true;

    # Explicitly set remotes (overrides default), keep flathub
    remotes = [
      {
        name = "flathub";
        location = "https://flathub.org/repo/flathub.flatpakrepo";
      }
    ];

    # Install user-scoped apps
    packages = [
      { appId = "dev.zed.Zed"; origin = "flathub"; }
      { appId = "com.spotify.Client"; origin = "flathub"; }
      # Add more like: { appId = "com.visualstudio.code"; origin = "flathub"; }
    ];

    overrides = {
      "dev.zed.Zed" = {
        Context = {
          filesystems = [
            "xdg-config/zed:rw"
          ];
        };
      };
    };

    # Optionally auto-update on activation (can slow down switches)
    update.onActivation = false;
  };
}


