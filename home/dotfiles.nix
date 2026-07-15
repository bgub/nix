{
  config,
  lib,
  ...
}:
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
    "handoff"
    "loc"
    "pr-stack"
    "refactor-effect"
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

  piFiles = [
    "package-lock.json"
    "package.json"
    "tsconfig.json"
    "agent/cloak.json"
    "agent/service-tier.json"
    "agent/settings-extensions.json"
    "agent/settings.json"
  ];

  piExtensionFiles = [
    "git-interceptor.ts"
    "pi-cloak.ts"
    "save-md.ts"
  ];

  piLinks =
    lib.listToAttrs (
      map (name: {
        name = ".pi/${name}";
        value = mkForcedHomeFile ".pi/${name}";
      }) piFiles
    )
    // lib.listToAttrs (
      map (name: {
        name = ".pi/agent/extensions/${name}";
        value = mkForcedHomeFile ".pi/agent/extensions/${name}";
      }) piExtensionFiles
    );

in
{
  xdg.configFile = toXdg;

  # Files outside XDG config need home.file.
  home.file =
    claudeSkillLinks
    // piLinks
    // {
      ".agents/AGENTS.md" = mkForcedHomeFile ".agents/AGENTS.md";
      ".agents/skills" = mkForcedHomeFile ".agents/skills";
      ".claude/CLAUDE.md" = mkForcedHomeFile ".agents/AGENTS.md";
      ".codex/AGENTS.md" = mkForcedHomeFile ".agents/AGENTS.md";
      ".pi/agent/AGENTS.md" = mkForcedHomeFile ".agents/AGENTS.md";
      "Library/Application Support/com.mitchellh.ghostty/config.ghostty" =
        mkForcedHomeFile "ghostty/config.ghostty";
    };
}
