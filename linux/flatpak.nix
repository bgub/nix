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
      { appId = "dev.zed.Zed"; origin = "flathub"; }
      { appId = "com.spotify.Client"; origin = "flathub"; }
      { appId = "md.obsidian.Obsidian"; origin = "flathub"; }
      { appId = "org.signal.Signal"; origin = "flathub"; }
      # Add more like: { appId = "com.visualstudio.code"; origin = "flathub"; }
    ];

    # Optionally auto-update on activation (can slow down switches)
    update.onActivation = false;
  };

  # Simple symlink: make ~/.local/bin/zed point to the Flatpak-exported binary
  home.file.".local/bin/zed".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.local/share/flatpak/exports/bin/dev.zed.Zed";
}


