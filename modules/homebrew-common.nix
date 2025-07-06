{ ... }:
{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      upgrade = true;
      cleanup = "zap";
    };

    caskArgs.no_quarantine = true;
    global.brewfile = true;

    # only add homebrew packages
    # if we can't find them in nixpkgs
    casks = [ ];
    brews = [ ];
    taps = [ ];
  };
}
