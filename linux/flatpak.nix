{ config, ... }:
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
      {
        appId = "dev.edfloreshz.CosmicTweaks";
        origin = "flathub";
      }
      {
        appId = "dev.DBrox.CosmicSystemMonitor";
        origin = "flathub";
      }
      {
        appId = "io.github.cosmic_utils.cosmic-ext-applet-clipboard-manager";
        origin = "flathub";
      }
      {
        appId = "dev.DBrox.CosmicSystemMonitor";
        origin = "flathub";
      }
    ];

    # Optionally auto-update on activation (can slow down switches)
    update.onActivation = false;
  };

  # Simple symlink: make ~/.local/bin/zed point to the Flatpak-exported binary
  # home.file.".local/bin/zed".source =
  # config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.local/share/flatpak/exports/bin/dev.zed.Zed";
}
