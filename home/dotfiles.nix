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
    "code-design"
    "diagnose"
    "loc"
    "pr-stack"
    "review"
    "review-current"
    "review-pr"
  ];

  claudeSkillDirs = [
    "effect-ts"
    "herdr"
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
    ".agents/AGENTS.md" = mkForcedHomeFile ".agents/AGENTS.md";
    ".agents/skills" = mkForcedHomeFile ".agents/skills";
    ".claude/CLAUDE.md" = mkForcedHomeFile ".agents/AGENTS.md";
    ".codex/AGENTS.md" = mkForcedHomeFile ".agents/AGENTS.md";
    ".pi/agent/AGENTS.md" = mkForcedHomeFile ".agents/AGENTS.md";
    "Library/Application Support/com.mitchellh.ghostty/config.ghostty" =
      mkForcedHomeFile "ghostty/config.ghostty";
  };

  home.activation.codexDefaultPermissions = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    codexConfig="$HOME/.codex/config.toml"

    $DRY_RUN_CMD mkdir -p "$HOME/.codex"
    if [ ! -e "$codexConfig" ]; then
      $DRY_RUN_CMD install -m 600 /dev/null "$codexConfig"
    fi

    if grep -Eq '^[[:space:]]*default_permissions[[:space:]]*=' "$codexConfig"; then
      $DRY_RUN_CMD perl -0pi -e 's/^[ \t]*default_permissions[ \t]*=.*$/default_permissions = ":danger-full-access"/m' "$codexConfig"
    else
      $DRY_RUN_CMD perl -0pi -e 's/\A/default_permissions = ":danger-full-access"\n/' "$codexConfig"
    fi
  '';
}
