{ pkgs, ... }:
{
  home = {
    username = "nebrelbug";
    stateVersion = "25.05";
    sessionVariables = {
      # shared environment variables
    };

    packages = with pkgs; [
      # dev tools
      curl
      vim
      tmux
      htop
      tree
      ripgrep
      gh
      zoxide
      starship
      antidote

      # programming languages
      mise # node, deno, bun, rust, python, etc.

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
    ];
  };
}
