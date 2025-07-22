# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a NixOS/Home Manager dotfiles repository for WSL environments, using Nix Flakes for declarative configuration management. The repository manages system and user configurations for two machines: `desktop` (x86_64-linux) and `zenbook` (aarch64-linux).

## Key Commands

### System Updates
```bash
# Quick Home Manager update (user configuration only)
./home/home-update

# Full NixOS system rebuild
./home/flakes-update
```

### Flake Operations
```bash
# Update flake dependencies
nix flake update

# Check flake configuration
nix flake check

# Show flake outputs
nix flake show
```

### Neovim Development
```bash
# Three Neovim versions are available
nvim         # Stable version
nvim-nightly # Nightly version
nvim-legacy  # v0.10.4

# When modifying Neovim config, test changes with
nvim -u home/nvim/init.lua
```

## Architecture & Key Components

### Configuration Structure
- **`flake.nix`**: Main entry point defining system configurations
- **`configuration.nix`**: NixOS system-level settings with WSL-specific configurations
- **`home.nix`**: Home Manager configuration for user-level packages and dotfiles
- **`/home/`**: Contains all application-specific configurations (nvim, git, zsh, etc.)

### Security & Secrets
- Uses SOPS with age encryption for secrets management
- Secrets stored in `secrets/secrets.yaml`
- Age keys must be placed at `~/.config/sops/age/keys.txt` (never commit)
- Pre-commit hook prevents accidental key commits

### Neovim Configuration
The repository contains extensive Neovim configurations in `/home/nvim/`:
- Plugin management via Lazy.nvim
- LSP configurations for multiple languages
- Japanese input support with SKKeleton
- AI coding assistance (Claude Code, CodeCompanion)
- Custom settings split across `lua/setting/` directory

### Development Environment
Supports multiple programming languages with corresponding LSPs:
- JavaScript/TypeScript (typescript-language-server)
- Python (pyright)
- Nix (nixd)
- Lua (lua-language-server)
- And many others defined in `home.nix`

## Important Notes

1. **Always test configuration changes** before committing using the update scripts
2. **Never commit sensitive files** - the pre-commit hook blocks `keys.txt` patterns
3. **WSL-specific**: This setup is optimized for WSL and includes custom notification handling
4. **Japanese language support**: Many configurations include Japanese comments and IME support