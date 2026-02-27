{ ... }:
{
  imports = [
    ./flatpak.nix
  ];

  # Linux-specific environment tweaks
  home.sessionPath = [
    "$HOME/.termcast/compiled/tuitube/bin"
    "$HOME/.opencode/bin"
  ];
}
