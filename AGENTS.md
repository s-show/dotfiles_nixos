# Repository Guidelines

## Project Structure & Module Organization
This repository is a Nix Flakes-based dotfiles setup for NixOS on WSL. Core entry points are `flake.nix`, `configuration.nix`, and `home.nix`. Machine targets are defined in `flake.nix` as `desktop` and `zenbook`.

Most user-facing configuration lives under `home/`:
- `home/nvim`, `home/nvim_ime`, `home/nvim_demo`, `home/nvim_minimum`: Neovim variants
- `home/zsh`, `home/tmux-which-key`, `home/superfile`: shell and terminal tooling
- `home/scripts`: helper scripts used by Home Manager symlinks
- `home/packages`: local Nix package definitions

Encrypted secrets live in `secrets/secrets.yaml`; age key material must stay outside the repo.

## Build, Test, and Development Commands
- `nix flake check`: validate flake evaluation and module wiring
- `nix flake show`: inspect available outputs and machine names
- `nix flake update`: refresh flake inputs and update `flake.lock`
- `./home/scripts/flakes-update.sh`: run the full system rebuild workflow
- `nvim -u home/nvim/init.lua`: test the main Neovim config in isolation

Use the smallest command that proves the change. For example, a Zsh edit usually needs `nix flake check`, while a Neovim plugin change should also be smoke-tested with `nvim -u ...`.

## Coding Style & Naming Conventions
Use 2-space indentation in Nix files and preserve the existing Lua style in `home/nvim/**`. Keep module names descriptive and file names lowercase with hyphens or underscores, matching existing patterns such as `wsl-notify-send.nix` and `statusline-command.sh`.

Prefer small, focused modules over large mixed-purpose files. Use `nixfmt-rfc-style` for Nix formatting when needed. Do not commit generated secret material or machine-local paths.

## Testing Guidelines
There is no dedicated unit test suite. Validation is command-driven:
- run `nix flake check` for all config changes
- run the affected script directly when editing `home/scripts/*`
- open the relevant Neovim profile when editing `home/nvim*`

Document any manual verification in the PR when behavior cannot be checked automatically.

## Commit & Pull Request Guidelines
Recent history uses short, imperative commit messages, often in Japanese, for example `tmux の操作性アップのための設定を追加`. Keep commits scoped to one change.

PRs should include a short summary, affected machine targets if relevant, validation commands run, and screenshots only when changing visible terminal UI behavior. Never include `keys.txt` or decrypted secrets; the pre-commit hook blocks `keys.txt` by name.
