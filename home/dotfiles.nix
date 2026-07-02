{ config, lib, ... }:
let
  repoRoot = "${config.home.homeDirectory}/.config/nix/dotfiles";
  mkSource = repoRel: config.lib.file.mkOutOfStoreSymlink "${repoRoot}/${repoRel}";
  mkHomeFile = repoRel: {
    source = mkSource repoRel;
  };
  mkForcedHomeFile =
    repoRel:
    (mkHomeFile repoRel)
    // {
      force = true;
    };

  # map of XDG config-relative paths -> repo-relative paths
  files = {
    # Zed settings
    "zed/settings.json" = "zed/settings.json";
    "zed/keymap.json" = "zed/keymap.json";
    "zed/tasks.json" = "zed/tasks.json";
    "fontconfig/fonts.conf" = "fontconfig/fonts.conf";
    "aerospace/aerospace.toml" = "aerospace/aerospace.toml";
    "ghostty/config.ghostty" = "ghostty/config.ghostty";
    # "alacritty/alacritty.toml" = "alacritty/alacritty.toml";
  };

  toXdg = lib.mapAttrs (relPath: repoRel: {
    source = mkSource repoRel;
    force = true;
  }) files;
in
{
  xdg.configFile = toXdg;

  # Files outside XDG config need home.file.
  home.file = {
    ".agents/skills" = mkForcedHomeFile ".agents/skills";
    ".claude/skills" = mkForcedHomeFile ".agents/skills";

    # Claude Code agents
    ".claude/agents/eval-issue.md" = mkHomeFile "claude/agents/eval-issue.md";

    "Library/Application Support/com.mitchellh.ghostty/config.ghostty" =
      mkForcedHomeFile "ghostty/config.ghostty";
  };
}
