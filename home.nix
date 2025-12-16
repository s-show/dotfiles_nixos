{ config, pkgs, lib, inputs, ... }:

let
  # Package sets
  nixpkgs-stable = inputs.nixpkgs.legacyPackages.${pkgs.system};
  oldNixpkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/c5dd43934613ae0f8ff37c59f61c507c2e8f980d.tar.gz";
  }) { };

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
    v0104 = oldNixpkgs.neovim-unwrapped;
    # Stable version from inputs
    # flake.nix の overlay 設定により neovim-unwrapped が nightly 版に置き換えられているので、
    # nixpkgsの安定版を明示的に取得
    stable = nixpkgs-stable.neovim-unwrapped;
    # Nightly version from overlay
    nightly = pkgs.neovim-unwrapped;
  };

  # Neovim nightly version from overlay
  neovim_0104 = oldNixpkgs.wrapNeovimUnstable neovim-sources.v0104 commonWrapperArgs;

  # Neovim stable version
  neovim-stable = nixpkgs-stable.wrapNeovimUnstable neovim-sources.stable commonWrapperArgs;

  # Neovim nightly version from overlay
  neovim-nightly = pkgs.wrapNeovimUnstable neovim-sources.nightly commonWrapperArgs;

  # Create wrapper script for nvim-stable
  nvim-stable-wrapper = pkgs.writeShellScriptBin "nvim-stable" ''
    exec ${neovim-stable}/bin/nvim "$@"
  '';
  nvim-0104-wrapper = pkgs.writeShellScriptBin "nvim-0104" ''
    exec ${neovim_0104}/bin/nvim "$@"
  '';

  # wsl-notify-send パッケージをインポート
  wsl-notify-send = import ./home/packages/wsl-notify-send.nix { inherit pkgs lib; };

  # node2nix を組み込む
  nodePkgs = pkgs.callPackage ./home/node2nix { inherit pkgs; };

  # zellij のプラグインをインストール
  zellijForgotWasm = pkgs.fetchurl {
    url = "https://github.com/karimould/zellij-forgot/releases/latest/download/zellij_forgot.wasm";
    hash = "sha256-MRlBRVGdvcEoaFtFb5cDdDePoZ/J2nQvvkoyG6zkSds="; # 後で埋める
  };
  zjpane = pkgs.fetchurl {
    url = "https://github.com/FuriouZz/zjpane/releases/latest/download/zjpane.wasm ";
    hash = "sha256-N2u0nPY//EpnJ6YoFGgoS7taL3S/SxfrE2qKfgywqt4="; # 後で埋める
  };
  zellij-harpoon = import ./home/packages/zellij-harpoon.nix { inherit pkgs lib; };

  # User configuration constants
  username = "s-show";
  homeDirectory = "/home/${username}";
  stateVersion = "25.05";
  mkDotfileSymlink = path: config.lib.file.mkOutOfStoreSymlink "${homeDirectory}/.dotfiles/${path}";
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
      lazysql
      nix-direnv
      age
      sops
      nodejs_24
      node2nix
      nodePkgs."vscode-languageserver-protocol-3.17.5"

      # Shell and terminal
      starship
      zellij
      zsh-abbr
      nb
      superfile

      # Programming languages and runtimes
      # cl
      # python313  # Serenaと競合するため削除。プロジェクトごとにnix-shellで管理
      lua51Packages.luarocks-nix
      libgcc
      gnumake
      gcc

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
      bash-language-server
      kdlfmt

      # Media and display
      libsixel
      timg
      chafa
      vhs

      # Fonts
      nerd-fonts.jetbrains-mono
      notonoto

      # Neovim packages
      neovim-nightly # nvim コマンドで nightly 版を起動
      nvim-stable-wrapper # nvim-stable コマンドで安定版を起動
      nvim-0104-wrapper # nvim-0104 コマンドで v0.10.4 を起動

      # misc tools
      wsl-notify-send
      firefox

      # AI coding tools
      inputs.serena.packages.${pkgs.system}.default
      gemini-cli
      codex
      claude-code
    ];
  };

  # Enable Home Manager
  programs.home-manager.enable = true;

  # Dotfiles management
  home.file = {
    ".config/starship.toml".source = mkDotfileSymlink "home/starship.toml";
    ".config/superfile".source = mkDotfileSymlink "home/superfile";
    # Neovim
    ".config/nvim".source = mkDotfileSymlink "home/nvim";
    ".config/nvim_ime".source = mkDotfileSymlink "home/nvim_ime";
    ".config/nvim_demo".source = mkDotfileSymlink "home/nvim_demo";
    ".config/nvim_minimum".source = mkDotfileSymlink "home/nvim_minimum";
    ".local/bin/nvim_ime".source = mkDotfileSymlink "home/nvim_ime.sh";
    ".local/bin/nvim_demo".source = mkDotfileSymlink "home/nvim_demo.sh";
    ".local/bin/nvim_minimum".source = mkDotfileSymlink "home/nvim_minimum.sh";
    # Zellij 
    ".config/zellij/config.kdl".source = mkDotfileSymlink "home/zellij/config.kdl";
    ".config/zellij/layout_vertical.kdl".source = mkDotfileSymlink "home/zellij/layout_vertical.kdl";
    ".config/zellij/plugins/zellij_forgot.wasm".source = zellijForgotWasm;
    ".config/zellij/plugins/zjpane.wasm".source = zjpane;
    ".config/zellij/plugins/harpoon.wasm".source = "${zellij-harpoon}/share/zellij/plugins/harpoon.wasm";
    # my script
    ".local/bin/home-update".source = mkDotfileSymlink "home/home-update";
    ".local/bin/flakes-update".source = mkDotfileSymlink "home/flakes-update.sh";
    ".local/bin/flakes-and-node2nix-update".source =
      mkDotfileSymlink "home/flakes-and-node2nix-update.sh";
    ".local/bin/notify".source = mkDotfileSymlink "home/notify.sh";
    ".local/bin/nbw".source = mkDotfileSymlink "home/wrap_nb.sh";
    ".local/bin/statusline-command".source = mkDotfileSymlink "home/statusline-command.sh";
    ".local/bin/claude_wrapper".source = mkDotfileSymlink "home/claude_wrapper.sh";
    ".local/bin/gemini_wrapper".source = mkDotfileSymlink "home/gemini_wrapper.sh";
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
