# Personal Nix Configuration

My personal system configuration using Nix flakes, Darwin, and Home Manager.

## About

This repository contains my declarative system configuration for macOS, managing packages, shell setup, development tools, and system settings through Nix.

**Author:** Ben Gubler 

## Quick Start

```bash
# Clone the repository
git clone https://github.com/bgub/nix-config ~/.config/nix
cd ~/.config/nix

# macOS
darwin-rebuild switch --flake .#work-macbook

# Linux (Fedora or other non-NixOS)
nix run home-manager/master -- switch --flake .#$(whoami)

# Or use the portable alias after initial setup (both macOS and Linux)
nix-switch
```

### Declarative Flatpaks (Linux)

Flatpaks are managed with [`nix-flatpak`](https://github.com/gmodena/nix-flatpak?tab=readme-ov-file). Linux-only config lives in `linux/flatpak.nix` and is imported by the flake for `homeConfigurations`.

- Remotes are set to Flathub
- Packages include Zed (`dev.zed.Zed`)

Change the list in `linux/flatpak.nix`, then:

```bash
nix-switch
```

## Set Zsh as your login shell (Linux/Fedora)

On non-NixOS Linux, setting the login shell is a system setting and not reliably handled by Home Manager. Prefer using the Zsh provided by Nix:

```bash
# Use Zsh from Nix (recommended)
ZSH_PATH="$(command -v zsh)"        # typically ~/.nix-profile/bin/zsh
echo "$ZSH_PATH" | sudo tee -a /etc/shells
chsh -s "$ZSH_PATH" "$USER"
# Log out and back in, then verify:
echo $SHELL
```

Alternative (system Zsh):

```bash
sudo dnf install -y zsh
chsh -s /usr/bin/zsh "$USER"
```

Your Home Manager config already enables Zsh, completions, autosuggestions, and Starship.

## Structure

- `flake.nix` - Main flake configuration
- `hosts/` - Host-specific configurations
- `modules/` - Shared configuration modules
- `platforms/` - Platform-specific settings

## Features

- Development tools managed with [mise](https://mise.jdx.dev/) (Node.js, Python, Rust, etc.)
- Shell configuration with Zsh, Starship, and useful aliases
- Git setup with common ignores and GitHub integration
- Custom Next.js development utilities
- Automatic garbage collection and store optimization
- Declarative Flatpak apps (simple sync script)

## Credits

- [Ethan Niser](https://github.com/ethanniser) for his [config repo](https://github.com/ethanniser/config) which I used as a reference for this project.
- David Haupt's excellent [tutorial series](https://davi.sh/blog/2024/01/nix-darwin/) which (although slightly outdated) helped me understand the basics of Nix.