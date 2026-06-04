{ config, ... }: {
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      la = "ls -la";
      ".." = "cd ..";
      zed = "zeditor";
    };

    # Place small customizations in initContent (initExtra is deprecated)
    initContent = ''
      # helper to quickly reload shell config
      reload-zsh() { exec "$SHELL" -l; }

      # initialize fnm (Fast Node Manager)
      if command -v fnm >/dev/null 2>&1; then
        eval "$(fnm env --use-on-cd)"
      fi

      # initialize Vite+
      if [[ -r "$HOME/.vite-plus/env" ]]; then
        source "$HOME/.vite-plus/env"
      fi

      # Keep Ghostty shell integration active after exec/reload-zsh.
      if [[ -n "$GHOSTTY_RESOURCES_DIR" && -r "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration" ]]; then
        source "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration"
      fi

      # Terminal key sequences used by Ghostty and common xterm-compatible terms.
      for keymap in emacs viins vicmd; do
        bindkey -M "$keymap" '^[[1;5D' backward-word
        bindkey -M "$keymap" '^[[1;5C' forward-word
        bindkey -M "$keymap" '^[[3~' delete-char
      done
    '';
  };

  programs.fzf = {
    enable = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
    changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
  };

  programs.zoxide = {
    enable = true;
  };

  programs.eza = {
    enable = true;
    git = true;
    icons = "auto";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      character = {
        success_symbol = "[λ](bold green)";
        error_symbol = "[λ](bold red)";
      };
    };
  };
}
