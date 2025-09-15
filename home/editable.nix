{ config, lib, ... }:
let
  repoRoot = "${config.home.homeDirectory}/.config/nix/dotfiles";

  # Map of XDG config-relative paths -> repo-relative paths
  files = {
    # Zed settings
    "zed/settings.json" = "zed/settings.json";
    "zed/keymap.json" = "zed/keymap.json";
    # Add more entries here as needed, e.g.:
    # "alacritty/alacritty.toml" = "alacritty/alacritty.toml";
    # "cursor/settings.json" = "cursor/settings.json";
  };

  toXdg = lib.mapAttrs (relPath: repoRel: {
    source = config.lib.file.mkOutOfStoreSymlink "${repoRoot}/${repoRel}";
    # no 'force' so Home Manager errors if a file already exists
  }) files;
in
{
  xdg.configFile = toXdg;
  # Also link the Flatpak Zed paths to the same repo files
  home.file = {
    ".var/app/dev.zed.Zed/config/zed/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${repoRoot}/zed/settings.json";
    ".var/app/dev.zed.Zed/config/zed/keymap.json".source = config.lib.file.mkOutOfStoreSymlink "${repoRoot}/zed/keymap.json";
  };
}


