{ ... }:
{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };

    caskArgs.no_quarantine = true;
    global.brewfile = true;

    # homebrew is best for GUI apps
    # nixpkgs is best for CLI tools
    casks = [
      # OS enhancements
      "nikitabobko/tap/aerospace"
      "ollama"
      "opencode-desktop"
      "cleanshot"
      "hiddenbar"
      "karabiner-elements"
      "raycast"
      "betterdisplay"

      # dev
      "cursor"
      "ghostty"
      "visual-studio-code"
      "zed"

      # messaging
      "discord"
      "slack"
      "signal"

      # other
      "1password"
      "anki"
      "brave-browser"
      "obsidian"
      "protonvpn"
      "tailscale"
      "spotify"
      "thebrowsercompany-dia"
      "zen"
    ];
    brews = [
      "docker"
      "colima"
      "anomalyco/tap/opencode"
      "FelixKratz/formulae/borders"
    ];
    taps = [
      "nikitabobko/tap"
      "anomalyco/tap"
      "FelixKratz/formulae"
    ];
  };
}
