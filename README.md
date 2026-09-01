# Workstation Configuration

My workstation configuration for Pop!_OS, macOS, and NixOS.

## Pop!_OS

Ansible installs packages and tools; Dotter links editable configuration files,
including curated COSMIC desktop settings, directly from this repository.

```bash
git clone https://github.com/bgub/nix ~/.config/nix
cd ~/.config/nix
./bootstrap
```

The first run asks for sudo once. Log out afterward to activate Zsh as the login
shell. To apply only part of the configuration, select its tag:

```bash
./bootstrap --tags base
./bootstrap --tags devtools
./bootstrap --tags gui
```

Use `./update` for routine system maintenance. It upgrades APT packages, runs
the bootstrap, and updates user Flatpaks. It is also safe to use for the first
setup.

- `base` installs the shell, Dotter, and fonts.
- `devtools` installs terminal tools, language runtimes, and editors.
- `gui` installs native desktop apps and user Flatpaks.

## macOS and NixOS

These systems remain Nix-managed:

```bash
# macOS
darwin-rebuild switch --flake .#work-macbook

# NixOS
sudo nixos-rebuild switch --flake .#xps15
```

## Repository layout

- `ansible/` — Pop!_OS packages and tools
- `.dotter/` — Pop!_OS dotfile selection
- `dotfiles/` — shared editable configuration
- `darwin/`, `nixos/`, and `home/` — Nix-managed systems
- `bootstrap` — Pop!_OS entrypoint
