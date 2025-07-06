# Personal Nix Configuration

My personal system configuration using Nix flakes, Darwin, and Home Manager.

## About

This repository contains my declarative system configuration for macOS, managing packages, shell setup, development tools, and system settings through Nix.

**Author:** Ben Gubler 

## Quick Start

```bash
# Clone the repository
git clone https://github.com/nebrelbug/nix-config ~/.config/nix
cd ~/.config/nix

# Build and switch to the configuration
darwin-rebuild switch --flake .#work-macbook

# Or use the alias after initial setup
nix-switch
```

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

## Credits

- [Ethan Niser](https://github.com/ethanniser) for his [config repo](https://github.com/ethanniser/config) which I used as a reference for this project.
- David Haupt's excellent [tutorial series](https://davi.sh/blog/2024/01/nix-darwin/) which (although slightly outdated) helped me understand the basics of Nix.