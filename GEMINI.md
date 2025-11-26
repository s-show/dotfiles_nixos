# GEMINI.md

This file provides context and guidance for Gemini when working with this repository.

## Project Overview

This is a **NixOS/Home Manager dotfiles repository** designed for **WSL (Windows Subsystem for Linux)** environments. It utilizes **Nix Flakes** for declarative configuration management, handling system and user settings for two primary machine profiles:
*   **desktop**: `x86_64-linux`
*   **zenbook**: `aarch64-linux`

The repository centralizes configuration for shell environments (Zsh, Starship), editors (Neovim), and various development tools, ensuring a consistent experience across machines.

## Architecture & Key Components

*   **`flake.nix`**: The entry point defining the NixOS system configurations and inputs (nixpkgs, home-manager, sops-nix, etc.).
*   **`configuration.nix`**: System-level NixOS settings, including WSL-specific optimizations.
*   **`home.nix`**: Home Manager configuration defining user packages, dotfile symlinks, and environment variables.
*   **`home/`**: Directory containing application-specific configurations:
    *   **`nvim/`**: Comprehensive Neovim configuration (Lazy.nvim, LSPs, Japanese IME via SKKeleton, AI integration).
    *   **`zsh.nix`**, **`git.nix`**, **`fzf.nix`**: Modularized configurations for specific tools.
    *   **scripts**: Custom maintenance scripts like `home-update` and `flakes-update.sh`.
*   **`secrets/`**: Encrypted secrets managed by **SOPS** with **age**.

## Key Commands

### System Maintenance
*   **Update User Config (Home Manager):**
    ```bash
    ./home/home-update
    ```
*   **Full System Rebuild (NixOS + Home Manager):**
    ```bash
    ./home/flakes-update
    ```
*   **Update Flake Inputs:**
    ```bash
    nix flake update
    ```

### Neovim
The system provides multiple Neovim versions for testing and stability:
*   **`nvim` / `neovim-nightly`**: The default alias, points to the nightly version.
*   **`nvim-stable`**: The stable release from nixpkgs.
*   **`nvim-0104`**: A legacy version (v0.10.4).

To test Neovim configuration changes safely:
```bash
nvim -u home/nvim/init.lua
```

## Development Conventions

*   **Configuration Management**: All major config changes should be done via `home.nix` or the specific modules in `home/`. Avoid manual edits to generated files in `~/.config/` as they are symlinked from the store or this repo.
*   **Secrets**: Never commit plain-text secrets. Use SOPS to encrypt `secrets/secrets.yaml`. Ensure the age key is present at `~/.config/sops/age/keys.txt` (but gitignored).
*   **Formatting**: Nix files are typically formatted with `nixfmt`.
*   **AI Integration**: The environment includes tools like `claude-code`, `serena`, and custom Neovim plugins for AI assistance.

## Directory Structure Highlights

*   `/.dotfiles`: Root of the repository.
*   `/home/s-show/.dotfiles/home/nvim`: Main Neovim configuration logic.
*   `/home/s-show/.dotfiles/home/packages`: Custom Nix expressions for packages not in nixpkgs (e.g., `wsl-notify-send`).
