#!/usr/bin/env bash

(
  cd ~/.dotfiles
  node2nix -i ~/.dotfiles/home/node2nix/node-packages.json -o ~/.dotfiles/home/node2nix/node-packages.nix
  git add .
  sudo nixos-rebuild switch --flake . --impure --show-trace
)
