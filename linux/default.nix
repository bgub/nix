{ pkgs, inputs, ... }:
{
  imports = [
    ./flatpak.nix
  ];

  home.packages = [
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-advanced-masks
      droidcam-obs
    ];
  };

  services.flameshot = {
    enable = true;
    settings.General = {
      useGrimAdapter = true;
      disabledGrimWarning = true;
      disabledTrayIcon = true;
      showStartupLaunchMessage = false;
      contrastOpacity = 100;
      copyOnDoubleClick = true;
      showSidePanelButton = false;
      showHelp = false;
      showAbortNotification = false;
    };
  };
}
