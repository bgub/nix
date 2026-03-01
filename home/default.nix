{ username, pkgs, ... }:
{
  imports = [
    ./packages.nix
    ./git.nix
    ./shell.nix
    ./nvim.nix
    ./dotfiles.nix
  ];

  home = {
    username = username;
    homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
    stateVersion = "25.05";
    sessionPath = [ "$HOME/.local/bin" ];
    sessionVariables = {
      # shared environment variables
    };

    # create .hushlogin file to suppress login messages
    file.".hushlogin".text = "";
  };

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = null;
    templates = null;
    music = null;
    publicShare = null;
  };
}
