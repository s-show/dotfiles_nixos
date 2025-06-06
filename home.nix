{ config, pkgs, lib, inputs, ... }:
{
  # Home Manager needs a bit of information about you and the paths it should manage.
  home = rec {
    username = "s-show";
    homeDirectory = "/home/${username}";
    stateVersion = "25.05";
  };

  nixpkgs = {
    overlays = [
      inputs.neovim-nightly-overlay.overlays.default
    ];
  };

  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello
    wget
    gh
    fd
    bat
    tig
    eza
    ripgrep
    superfile
    starship
    zellij
    unzip
    cargo
    lua51Packages.luarocks-nix
    libgcc
    zig
    cl
    python313
    lua-language-server
    emmet-ls
    typescript-language-server
    vim-language-server
    vscode-langservers-extracted
    clang-tools
    nixd
    nixfmt-rfc-style
    eslint_d
    zsh-abbr
    nb
    deno
    nix-direnv
    libsixel
    timg
    go
    chafa
    jq
    nerd-fonts.jetbrains-mono
    age
    sops
    nkf
    (wrapNeovimUnstable neovim-unwrapped {
      wrapRc = false;
      wrapperArgs = [
        "--suffix"
        "LD_LIBRARY_PATH"
        ":"
        "${stdenv.cc.cc.lib}/lib"
      ];
    })
    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/s-show/etc/profile.d/hm-session-vars.sh
  #
  # home.sessionVariables = {
  #   EDITOR = "nvim";
  # };

  sops = {
    age.keyFile = "/home/s-show/.dotfiles/sops/age/keys.txt"; # must have no password!
    defaultSopsFile = ./secrets.yaml;
    defaultSymlinkPath = "/run/user/1001/secrets";
    defaultSecretsMountPoint = "/run/user/1001/secrets.d";
    secrets.OPENROUTER_API_KEY = {
      path = "${config.sops.defaultSymlinkPath}/OPENROUTER_API_KEY";
    };
  };

  # setting Neovim
  programs.neovim.plugins = [
    pkgs.vimPlugins.nvim-treesitter.withAllGrammars
  ];
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".config/starship.toml".source =
      config.lib.file.mkOutOfStoreSymlink "${builtins.toString config.home.homeDirectory}/.dotfiles/home/starship.toml";
    ".config/superfile".source =
      config.lib.file.mkOutOfStoreSymlink "${builtins.toString config.home.homeDirectory}/.dotfiles/home/superfile";
    ".config/nvim".source =
      config.lib.file.mkOutOfStoreSymlink "${builtins.toString config.home.homeDirectory}/.dotfiles/home/nvim";
    ".local/bin/home-update".source =
      config.lib.file.mkOutOfStoreSymlink "${builtins.toString config.home.homeDirectory}/.dotfiles/home/home-update";
  };

  home.activation = {
    prepareGithook = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      cp "${builtins.toString config.home.homeDirectory}/.dotfiles/home/git-pre-commit" "${builtins.toString config.home.homeDirectory}/.dotfiles/.git/hooks/pre-commit"
    '';
  };

  imports = [
    ./home/zsh.nix
    ./home/fzf.nix
    ./home/git.nix
    ./home/direnv.nix
    inputs.sops-nix.homeManagerModules.sops
  ];
}
