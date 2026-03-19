{ pkgs, inputs, lib, ... }:
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
      python3
      uv
      rustup
      gnumake
      qemu
      gcc
      pkgsCross.riscv64-embedded.buildPackages.gcc
      just
      cargo-generate
      elan # Lean 4 toolchain manager

      # apps
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      brave
      vivaldi
      alacritty
      kitty
      zed-editor
      helix
      ladybird
      code-cursor
      libreoffice
      obsidian
      grim
      gpu-screen-recorder
      voxtype
      kooha
      zotero
      baobab
      popsicle
      godot_4

      # misc
      nixd
      biome
      nixfmt
      yt-dlp
      ffmpeg
      unixtools.xxd
      wl-clipboard
      tcpdump
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
      ]
      ++ lib.optionals pkgs.stdenv.isLinux [
        google-chrome
        opencode-desktop
      ];
  };

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-advanced-masks
      droidcam-obs
    ];
  };

  services.flameshot = {
    enable = true;
    settings.General = {
      useGrimAdapter = true;
      disabledGrimWarning = true;
      disabledTrayIcon = true;
      showStartupLaunchMessage = false;
      contrastOpacity = 100;
      copyOnDoubleClick = true;
      showSidePanelButton = false;
      showHelp = false;
      showAbortNotification = false;
    };
  };
}
