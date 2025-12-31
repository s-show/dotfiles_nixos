#!/usr/bin/env bash

(
  cd ~/.dotfiles
  git add .
  sudo nixos-rebuild switch --flake . --impure --show-trace
)
