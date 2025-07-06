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
      mise
      # fnm
      # python3
      # deno
      # bun
      # rustup
      # uv

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
