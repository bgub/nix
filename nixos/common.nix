{ pkgs, ... }:

{
  # ── boot ──────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.systemd.enable = true;

  # ── networking ────────────────────────────────────────────────────────
  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;

  # ── locale & time ────────────────────────────────────────────────────
  time.timeZone = "America/Denver";
  i18n.defaultLocale = "en_US.UTF-8";

  # ── desktop (COSMIC) ─────────────────────────────────────────────────
  services.displayManager.cosmic-greeter.enable = true;
  services.desktopManager.cosmic.enable = true;
  services.system76-scheduler.enable = true;

  # ── audio (PipeWire) ──────────────────────────────────────────────────
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ── printing ──────────────────────────────────────────────────────────
  services.printing.enable = true;

  # ── user ──────────────────────────────────────────────────────────────
  users.users.bgub = {
    isNormalUser = true;
    description = "Ben Gubler";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };

  # ── programs ──────────────────────────────────────────────────────────
  programs.zsh.enable = true;
  programs.firefox.enable = true;
  programs.nix-ld.enable = true;

  # ── Nix settings ─────────────────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.optimise.automatic = true;

  # ── power / battery ──────────────────────────────────────────────────
  services.thermald.enable = true;

  # ── Tailscale ─────────────────────────────────────────────────────────
  services.tailscale.enable = true;
}
