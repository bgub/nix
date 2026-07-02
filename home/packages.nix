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
      time
      bat
      delta
      glow
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

      # runtimes/toolchains managed via packages
      fnm # Node/pnpm via Corepack; run: fnm env --use-on-cd
      bun
      deno
      python3
      uv
      rustup
      gnumake
      just
      cargo-generate
      elan # Lean 4 toolchain manager

      # editors
      helix

      # misc
      nixd
      biome
      nixfmt
      yt-dlp
      ffmpeg
      tcpdump

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

      # update flake inputs then rebuild
      (writeShellScriptBin "nix-update" ''
        set -euo pipefail
        echo "Updating flake inputs..."
        nix flake update --flake "$HOME/.config/nix"
        echo "Rebuilding..."
        exec nix-switch
      '')

      # enter a shell with cosmic applet build deps
      (writeShellScriptBin "cosmic-dev" ''
        exec nix-shell "$HOME/.config/nix/cosmic-shell.nix"
      '')
    ];
  };
}
