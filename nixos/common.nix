{ pkgs, ... }:

{
  # ── boot ──────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.systemd.enable = true;
  boot.plymouth.enable = true;

  # ── networking ────────────────────────────────────────────────────────
  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;
  networking.firewall.allowedTCPPorts = [ 8081 ];

  # ── locale & time ────────────────────────────────────────────────────
  time.timeZone = "America/Denver";
  i18n.defaultLocale = "en_US.UTF-8";

  # ── desktop (COSMIC) ─────────────────────────────────────────────────
  services.displayManager.cosmic-greeter.enable = true;
  services.displayManager.autoLogin = {
    enable = true;
    user = "bgub";
  };
  services.desktopManager.cosmic.enable = true;
  services.system76-scheduler.enable = true;
  environment.sessionVariables.COSMIC_DATA_CONTROL_ENABLED = 1;
  environment.localBinInPath = true;

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
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
  };

  # ── programs ──────────────────────────────────────────────────────────
  programs.zsh.enable = true;
  programs.firefox.enable = true;
  programs.firefox.preferences."widget.gtk.libadwaita-colors.enabled" = false;
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    glib
    nspr
    nss
    dbus
    atk
    at-spi2-atk
    at-spi2-core
    cups
    cairo
    pango
    gtk3
    mesa
    libdrm
    libgbm
    expat
    libxkbcommon
    udev
    alsa-lib
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxcb
  ];
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;
  services.flatpak.enable = true;

  # ── Nix settings ─────────────────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    max-jobs = "auto";
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.optimise.automatic = true;

  # ── firmware updates ─────────────────────────────────────────────
  services.fwupd.enable = true;

  # ── power / battery ──────────────────────────────────────────────────
  services.thermald.enable = true;

  # ── iPhone USB ────────────────────────────────────────────────────────
  services.usbmuxd.enable = true;
  environment.systemPackages = with pkgs; [
    # iPhone USB
    libimobiledevice
    ifuse

    # GUI apps
    brave
    vivaldi
    alacritty
    kitty
    zed-editor
    code-cursor
    ladybird
    libreoffice
    obsidian
    zotero
    godot_4
    google-chrome

    # Wayland / COSMIC tools
    grim
    wl-clipboard
    gpu-screen-recorder
    voxtype
    kooha
    baobab
    popsicle

    # dev tools
    gcc
    qemu
    unixtools.xxd
    ollama
    opencode
    opencode-desktop

    # cross-compilation
    pkgsCross.riscv64-embedded.buildPackages.gcc
  ];

  # ── Tailscale ─────────────────────────────────────────────────────────
  services.tailscale.enable = true;
}
