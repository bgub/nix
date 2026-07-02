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

  claudeSkillFiles = [
    "loc"
    "pr-stack"
    "review-current"
    "review-pr"
  ];

  claudeSkillDirs = [
    "effect-ts"
  ];

  claudeSkillLinks =
    lib.listToAttrs (
      map (name: {
        name = ".claude/skills/${name}/SKILL.md";
        value = mkForcedHomeFile ".agents/skills/${name}/SKILL.md";
      }) claudeSkillFiles
    )
    // lib.listToAttrs (
      map (name: {
        name = ".claude/skills/${name}";
        value = mkForcedHomeFile ".agents/skills/${name}";
      }) claudeSkillDirs
    );
in
{
  xdg.configFile = toXdg;

  # Files outside XDG config need home.file.
  home.file = claudeSkillLinks // {
    ".agents/skills" = mkForcedHomeFile ".agents/skills";

    "Library/Application Support/com.mitchellh.ghostty/config.ghostty" =
      mkForcedHomeFile "ghostty/config.ghostty";
  };
}
