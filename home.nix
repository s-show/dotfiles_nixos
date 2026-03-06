{ config, pkgs, lib, inputs, ... }:

let
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
    # Nightly version from overlay
    nightly = pkgs.neovim-unwrapped;
  };

  # Neovim nightly version from overlay
  neovim-nightly = pkgs.wrapNeovimUnstable neovim-sources.nightly commonWrapperArgs;

  # wsl-notify-send パッケージをインポート
  wsl-notify-send = import ./home/packages/wsl-notify-send.nix { inherit pkgs lib; };

  # node2nix を組み込む
  # nodePkgs = pkgs.callPackage ./home/node2nix { inherit pkgs; };

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
      nix-direnv
      age
      sops
      nodejs_24
      # node2nix
      # nodePkgs."vscode-languageserver-protocol-3.17.5"
      delta

      # Shell and terminal
      starship
      nb
      superfile
      sheldon
      tmux
      tmuxPlugins.continuum
      tmuxPlugins.resurrect
      tmuxPlugins.mode-indicator
      tmuxPlugins.tmux-which-key
      tmuxPlugins.tmux-fzf
      tmuxPlugins.tmux-thumbs
      tmuxPlugins.gruvbox
      tmuxPlugins.tmux-nova

      # Programming languages and runtimes
      lua51Packages.luarocks-nix
      libgcc
      gnumake
      gcc

      # Language servers and formatters
      lua-language-server
      vim-language-server
      # vscode-langservers-extracted
      nixd
      nixfmt-rfc-style
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

      # misc tools
      wsl-notify-send

      # AI coding tools
      inputs.serena.packages.${pkgs.system}.default
      gemini-cli
      codex
      claude-code

      # Path to windows App
      (pkgs.writeShellScriptBin "clip.exe" ''
        /mnt/c/windows/System32/clip.exe "$@"
      '')
      (pkgs.writeShellScriptBin "explorer.exe" ''
        /mnt/c/windows/explorer.exe "$@"
      '')
    ];
  };

  # Enable Home Manager
  programs.home-manager.enable = true;

  # Dotfiles management
  home.file = {
    # App
    ".config/starship.toml".source = mkDotfileSymlink "home/starship.toml";
    ".config/superfile".source = mkDotfileSymlink "home/superfile";
    # Neovim
    ".config/nvim".source = mkDotfileSymlink "home/nvim";
    ".config/nvim_ime".source = mkDotfileSymlink "home/nvim_ime";
    ".config/nvim_demo".source = mkDotfileSymlink "home/nvim_demo";
    ".config/nvim_minimum".source = mkDotfileSymlink "home/nvim_minimum";
    ".local/bin/nvim_ime".source = mkDotfileSymlink "home/scripts/nvim_ime.sh";
    ".local/bin/nvim_demo".source = mkDotfileSymlink "home/scripts/nvim_demo.sh";
    ".local/bin/nvim_minimum".source = mkDotfileSymlink "home/scripts/nvim_minimum.sh";
    # ZSH
    ".config/zsh".source = mkDotfileSymlink "home/zsh";
    ".config/sheldon/plugins.toml".source = mkDotfileSymlink "home/plugins.toml";
    # my script
    ".local/bin/flakes-update".source = mkDotfileSymlink "home/scripts/flakes-update.sh";
    ".local/bin/flakes-and-node2nix-update".source =
      mkDotfileSymlink "home/scripts/flakes-and-node2nix-update.sh";
    ".local/bin/notify".source = mkDotfileSymlink "home/scripts/notify.sh";
    ".local/bin/nbw".source = mkDotfileSymlink "home/scripts/wrap_nb.sh";
    ".local/bin/statusline-command".source = mkDotfileSymlink "home/scripts/statusline-command.sh";
    ".local/bin/claude_wrapper".source = mkDotfileSymlink "home/scripts/claude_wrapper.sh";
    ".local/bin/gemini_wrapper".source = mkDotfileSymlink "home/scripts/gemini_wrapper.sh";
    # tmux-which-key
    ".config/tmux/plugins/tmux-which-key/config.yaml".source = mkDotfileSymlink "home/tmux-which-key/config.yaml";
    ".local/share/tmux/plugins/tmux-which-key/init.tmux".source = mkDotfileSymlink "home/tmux-which-key/init.tmux";
  };

  # Home activation scripts
  home.activation = {
    prepareGithook = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      cp "${homeDirectory}/.dotfiles/home/git-pre-commit" \
         "${homeDirectory}/.dotfiles/.git/hooks/pre-commit"
    '';
  };

  # ssh setting
  programs.ssh.matchBlocks = {
    "github.com" = {
      addKeysToAgent = "yes";
    };
  };

  # Nix が管理するパスを環境変数として渡す
  home.sessionVariables = {
    WSL_NOTIFY_SEND = "${wsl-notify-send}/bin/wsl-notify-send.exe";
  };

  # Import additional modules
  imports = [
    ./home/zsh.nix
    ./home/fzf.nix
    ./home/git.nix
    ./home/direnv.nix
    ./home/tmux.nix
  ];
}
