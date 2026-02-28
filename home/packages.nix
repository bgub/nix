{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      # dev tools
      curl
      wget
      tmux
      htop
      tree
      ripgrep
      fd
      fzf
      eza
      gh
      zoxide
      lazygit
      jujutsu
      lazyjj
      claude-code
      opencode

      # runtimes/toolchains managed via packages
      fnm # Node/pnpm via Corepack; run: fnm env --use-on-cd
      bun
      deno
      uv
      rustup

      # apps
      brave
      zed-editor
      code-cursor
      obsidian
      flameshot
      obs-studio
      kooha

      # misc
      nixd
      biome
      nixfmt
      yt-dlp
      ffmpeg
      ollama

      # fonts
      nerd-fonts.fira-code
      nerd-fonts.fira-mono
      nerd-fonts.droid-sans-mono

      # portable nix-switch command available across shells
      (writeShellScriptBin "nix-switch" ''
        #!/usr/bin/env bash
        set -euo pipefail
        if [ "$(uname)" = "Darwin" ]; then
          exec sudo darwin-rebuild switch --flake "$HOME/.config/nix"
        elif [ -f /etc/NIXOS ]; then
          exec sudo nixos-rebuild switch --flake "$HOME/.config/nix#$(hostname)"
        else
          exec nix run home-manager/master -- switch --flake "$HOME/.config/nix#$USER"
        fi
      '')
    ];
  };
}
