{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      # dev tools
      curl
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

      # runtimes/toolchains managed via packages
      fnm # Node/pnpm via Corepack; run: fnm env --use-on-cd
      bun
      deno
      uv
      rustup

      # misc
      nil
      biome
      nixfmt-rfc-style
      yt-dlp
      ffmpeg
      ollama

      # fonts
      nerd-fonts.fira-code
      nerd-fonts.fira-mono

      # portable nix-switch command available across shells
      (writeShellScriptBin "nix-switch" ''
        #!/usr/bin/env bash
        set -euo pipefail
        if [ "$(uname)" = "Darwin" ]; then
          exec sudo darwin-rebuild switch --flake "$HOME/.config/nix"
        else
          exec nix run home-manager/master -- switch --flake "$HOME/.config/nix#$USER"
        fi
      '')
    ];
  };
}
