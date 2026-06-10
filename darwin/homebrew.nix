{ ... }:
{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
      extraEnv.HOMEBREW_NO_ENV_HINTS = "1";
    };

    caskArgs.no_quarantine = true;
    global.brewfile = true;

    taps = [
      "stripe/stripe-cli"
      "anomalyco/tap"
      "FelixKratz/formulae"
      "nikitabobko/tap"
    ];

    # homebrew is best for GUI apps
    # nixpkgs is best for CLI tools
    casks = [
      # OS enhancements
      "aerospace"
      "ollama-app"
      "opencode-desktop"
      "cleanshot"
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
      "notion"
      "obsidian"
      "proton-pass"
      "protonvpn"
      "tailscale-app"
      "spotify"
      "thebrowsercompany-dia"
      "zen"
    ];
    brews = [
      "awscli"
      "stripe"
      "docker"
      "colima"
      "anomalyco/tap/opencode"
      "borders"
    ];
  };
}
