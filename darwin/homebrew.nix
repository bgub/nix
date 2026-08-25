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

    global.brewfile = true;

    # Declare trust in the Brewfile so `brew bundle --cleanup` preserves it.
    # Keep this item-specific instead of trusting every package in each tap.
    extraConfig = ''
      tap "stripe/stripe-cli", trusted: { formula: "stripe" }
      tap "anomalyco/tap", trusted: { formula: "opencode" }
      tap "FelixKratz/formulae", trusted: { formula: "borders" }
      tap "nikitabobko/tap", trusted: { cask: "aerospace" }
    '';

    # homebrew is best for GUI apps
    # nixpkgs is best for CLI tools
    casks = [
      # OS enhancements
      "aerospace"
      "karabiner-elements"
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
