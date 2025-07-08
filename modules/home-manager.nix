{ pkgs, lib, ... }:
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

    # create .hushlogin file to suppress login messages
    file.".hushlogin".text = "";

    # activation script to set up mise configuration
    activation = {
      setupMise = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        # use the virtual environment created by uv 
        # ${pkgs.mise}/bin/mise settings set python.uv_venv_auto true

        # enable corepack (pnpm, yarn, etc.)
        ${pkgs.mise}/bin/mise set MISE_NODE_COREPACK=true

        # disable warning about */.node-version files
        ${pkgs.mise}/bin/mise settings add idiomatic_version_file_enable_tools "[]"

        # set global tool versions (auto_install will handle installation)
        ${pkgs.mise}/bin/mise use --global node@lts
        ${pkgs.mise}/bin/mise use --global bun@latest
        ${pkgs.mise}/bin/mise use --global deno@latest
        ${pkgs.mise}/bin/mise use --global uv@latest
        ${pkgs.mise}/bin/mise use --global rust@stable
      '';
    };
  };
}
