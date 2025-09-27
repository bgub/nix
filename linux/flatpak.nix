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
      {
        name = "cosmic";
        location = "https://apt.pop-os.org/cosmic/cosmic.flatpakrepo";
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
        origin = "cosmic";
      }
      {
        appId = "io.github.cosmic_utils.cosmic-ext-applet-clipboard-manager";
        origin = "cosmic";
      }
    ];

    # Optionally auto-update on activation (can slow down switches)
    update.onActivation = false;
  };
}
