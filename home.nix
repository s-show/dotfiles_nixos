{ config, pkgs, lib, inputs, ... }:

let
  # Package sets
  pkgs_2411 = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/c5dd43934613ae0f8ff37c59f61c507c2e8f980d.tar.gz";
  }) {};
 
  # Common Neovim wrapper arguments
  commonWrapperArgs = {
    wrapRc = false;
    wrapperArgs = [
      "--suffix"
      "LD_LIBRARY_PATH"
      ":"
      "${pkgs.stdenv.cc.cc.lib}/lib"
    ];
  };
  # Neovim source packages
  neovim-sources = {
    # v0.10.4 from specific nixpkgs commit
    v0104 = pkgs_2411.neovim-unwrapped;
    # Stable version from inputs
    # flake.nix の overlay 設定により neovim-unwrapped が nightly 版に置き換えられている模様なので、
    # nixpkgsの安定版を明示的に取得
    stable = inputs.nixpkgs.legacyPackages.${pkgs.system}.neovim-unwrapped;
    # Nightly version from overlay
    nightly = pkgs.neovim;
  };
 
  # Neovim nightly version from overlay
  neovim_0104 = pkgs.wrapNeovimUnstable neovim-sources.v0104 commonWrapperArgs;

  # Neovim stable version
  neovim-stable =pkgs.wrapNeovimUnstable neovim-sources.stable commonWrapperArgs;
 
  # Neovim nightly version from overlay
  neovim-nightly =pkgs.wrapNeovimUnstable neovim-sources.nightly commonWrapperArgs;

  # Create wrapper script for nvim-stable
  nvim-stable-wrapper = pkgs.writeShellScriptBin "nvim-stable" ''
    exec ${neovim-stable}/bin/nvim "$@"
  '';
  nvim-0104-wrapper = pkgs.writeShellScriptBin "nvim-0104" ''
    exec ${neovim_0104}/bin/nvim "$@"
  '';

  # User configuration constants
  username = "s-show";
  homeDirectory = "/home/${username}";
  stateVersion = "25.05";
  mkDotfileSymlink = path: config.lib.file.mkOutOfStoreSymlink 
    "${homeDirectory}/.dotfiles/${path}";
in
{
  # Home Manager configuration
  home = {
    inherit username homeDirectory stateVersion;

    # Packages organized by category
    packages = with pkgs; [
      # Core utilities
      wget
      pkgs.file
      unzip
      jq
      nkf

      # Development tools
      gh
      fd
      bat
      tig
      eza
      ripgrep
      cargo
      zig
      go
      deno
      nix-direnv
      age
      sops

      # Shell and terminal
      starship
      zellij
      zsh-abbr
      nb
      superfile
     
      # Programming languages and runtimes
      cl
      python313
      lua51Packages.luarocks-nix
      libgcc

      # Language servers and formatters
      lua-language-server
      emmet-ls
      typescript-language-server
      vim-language-server
      vscode-langservers-extracted
      clang-tools
      nixd
      nixfmt-rfc-style
      eslint_d

      # Media and display
      libsixel
      timg
      chafa

      # Fonts
      nerd-fonts.jetbrains-mono

      # Neovim packages
      neovim-nightly # nvim コマンドで nightly 版を起動
      nvim-stable-wrapper # nvim-stable コマンドで nightly 版を起動
      nvim-0104-wrapper
    ];
  };

  # Neovim plugins
  programs.neovim.plugins = [
    pkgs.vimPlugins.nvim-treesitter.withAllGrammars
  ];

  # Enable Home Manager
  programs.home-manager.enable = true;

  # Dotfiles management
  home.file = {
    ".config/starship.toml".source = mkDotfileSymlink "home/starship.toml";
    ".config/superfile".source = mkDotfileSymlink "home/superfile";
    ".config/nvim".source = mkDotfileSymlink "home/nvim";
    ".local/bin/home-update".source = mkDotfileSymlink "home/home-update";
  };

  # Home activation scripts
  home.activation = {
    prepareGithook = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      cp "${homeDirectory}/.dotfiles/home/git-pre-commit" \
         "${homeDirectory}/.dotfiles/.git/hooks/pre-commit"
    '';
  };

  # Import additional modules
  imports = [
    ./home/zsh.nix
    ./home/fzf.nix
    ./home/git.nix
    ./home/direnv.nix
  ];
}
