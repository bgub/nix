{ config, lib, ... }:
let
  repoRoot = "${config.home.homeDirectory}/.config/nix/dotfiles";

  # Map of XDG config-relative paths -> repo-relative paths
  files = {
    # Zed settings
    "zed/settings.json" = "zed/settings.json";
    "zed/keymap.json" = "zed/keymap.json";
    "zed/tasks.json" = "zed/tasks.json";
    "fontconfig/fonts.conf" = "fontconfig/fonts.conf";
    "cosmic/com.system76.CosmicTerm/v1/font_name" = "cosmic/term_font_name";
    "cosmic/com.system76.CosmicTerm/v1/show_headerbar" = "cosmic/term_show_headerbar";
    "cosmic/com.system76.CosmicComp/v1/autotile" = "cosmic/autotile";
    "cosmic/com.system76.CosmicComp/v1/xkb_config" = "cosmic/xkb_config";
    "cosmic/com.system76.CosmicAppletTime/v1/military_time" = "cosmic/military_time";
    "cosmic/com.system76.CosmicPanel/v1/entries" = "cosmic/panel_dock_entries";
    "cosmic/com.system76.CosmicPanel.Panel/v1/plugins_center" = "cosmic/panel_plugins_center";
    "cosmic/com.system76.CosmicPanel.Panel/v1/plugins_wings" = "cosmic/panel_plugins_wings";
    "cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom" = "cosmic/shortcuts_custom";
    # "alacritty/alacritty.toml" = "alacritty/alacritty.toml";
  };

  toXdg = lib.mapAttrs (relPath: repoRel: {
    source = config.lib.file.mkOutOfStoreSymlink "${repoRoot}/${repoRel}";
    # no 'force' so Home Manager errors if a file already exists
  }) files;
in
{
  xdg.configFile = toXdg;
}
