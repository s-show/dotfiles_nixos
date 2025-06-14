{ pkgs, lib, config, ... }:
{
  programs.zsh = {
    enable = true;
    autocd = true; # cdなしでファイルパスだけで移動
    enableCompletion = true; # 自動補完
    autosuggestion.enable = true; # 入力サジェスト
    syntaxHighlighting.enable = true; # シンタックスハイライト
    history.ignorePatterns = [
      "fg *"
      "exit *"
      "export *API*"
      "history *"
    ];
    zsh-abbr.enable = true;
    zsh-abbr.abbreviations = {
      cat = "bat %";
      ls = "eza --icons always --classify always %";
      la = "eza --icons always --classify always --all %";
      ll = "eza --icons always --long --all --git %";
      tree = "eza --icons always --classify always --tree %";
      grep = "rg '%' %";
      gitm = "git commit -m '%'";
      gitc = "git clone '%'";
      mkdir = "mkdir -p %";
      apply = "git add . && home-manager switch --flake .";
    };
    initContent =
      let
        zshConfigEarlyInit = lib.mkOrder 500 ''
          ABBR_DEFAULT_BINDINGS=0
          bindkey ";" abbr-expand-and-insert
          bindkey "Enter" abbr-expand-and-accept
        '';
        zshConfigLastInit = lib.mkOrder 1500 ''
          ABBR_SET_EXPANSION_CURSOR=1
          ABBR_SET_LINE_CURSOR=1
          compinit
          bindkey -e
          zstyle ':completion:*:default' menu select=1
          eval "$(direnv hook zsh)"
          export OPENROUTER_API_KEY=$(cat "/run/secrets/OPENROUTER_API_KEY")
        '';
      in
      lib.mkMerge [
        zshConfigEarlyInit
        zshConfigLastInit
      ];

    # initExtra = ''
    #   ABBR_SET_EXPANSION_CURSOR=1
    #   ABBR_SET_LINE_CURSOR=1
    #   compinit
    #   bindkey -e
    #   zstyle ':completion:*:default' menu select=1
    #   eval "$(direnv hook zsh)"
    # '';
  };
}
