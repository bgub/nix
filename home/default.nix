{ username, pkgs, ... }:
{
  imports = [
    ./packages.nix
    ./git.nix
    ./shell.nix
    ./mise.nix
    ./nvim.nix
    ./editable.nix
  ];

  home = {
    username = username;
    homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
    stateVersion = "25.05";
    sessionVariables = {
      # shared environment variables
    };

    # create .hushlogin file to suppress login messages
    file.".hushlogin".text = "";
  };
}
