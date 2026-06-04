{ config, lib, ... }:
let
  repoRoot = "${config.home.homeDirectory}/.config/nix/dotfiles";

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
    source = config.lib.file.mkOutOfStoreSymlink "${repoRoot}/${repoRel}";
    force = true;
  }) files;
in
{
  xdg.configFile = toXdg;

  # Files under ~/.claude (not XDG, so use home.file)
  home.file = {
    # Claude Code skills
    ".claude/skills/refactor/SKILL.md".source = config.lib.file.mkOutOfStoreSymlink "${repoRoot}/claude/skills/refactor.md";
    ".claude/skills/push/SKILL.md".source = config.lib.file.mkOutOfStoreSymlink "${repoRoot}/claude/skills/push.md";
    ".claude/skills/examine/SKILL.md".source = config.lib.file.mkOutOfStoreSymlink "${repoRoot}/claude/skills/examine.md";
    ".claude/skills/rebase/SKILL.md".source = config.lib.file.mkOutOfStoreSymlink "${repoRoot}/claude/skills/rebase.md";
    ".claude/skills/squash/SKILL.md".source = config.lib.file.mkOutOfStoreSymlink "${repoRoot}/claude/skills/squash.md";
    ".claude/skills/eval-issues/SKILL.md".source = config.lib.file.mkOutOfStoreSymlink "${repoRoot}/claude/skills/eval-issues.md";
    ".claude/skills/fresh-branch/SKILL.md".source = config.lib.file.mkOutOfStoreSymlink "${repoRoot}/claude/skills/fresh-branch.md";
    # Claude Code agents
    ".claude/agents/eval-issue.md".source = config.lib.file.mkOutOfStoreSymlink "${repoRoot}/claude/agents/eval-issue.md";
    # Shared skills for other agents (e.g. Codex)
    ".agents/skills".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.claude/skills";
    "Library/Application Support/com.mitchellh.ghostty/config.ghostty" = {
      source = config.lib.file.mkOutOfStoreSymlink "${repoRoot}/ghostty/config.ghostty";
      force = true;
    };
  };
}
