{ config, ... }: {
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      la = "ls -la";
      ".." = "cd ..";
    };

    # Place small customizations in initContent (initExtra is deprecated)
    initContent = ''
      # helper to quickly reload shell config
      reload-zsh() { exec "$SHELL" -l; }

      # initialize fnm (Fast Node Manager)
      if command -v fnm >/dev/null 2>&1; then
        eval "$(fnm env --use-on-cd)"
      fi

      # Ctrl+Left / Ctrl+Right for word movement (insert + normal modes)
      bindkey -M viins '^[[1;5D' backward-word
      bindkey -M viins '^[[1;5C' forward-word
      bindkey -M vicmd '^[[1;5D' backward-word
      bindkey -M vicmd '^[[1;5C' forward-word
    '';
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
    changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    git = true;
    icons = "auto";
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
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
