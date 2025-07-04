{ pkgs, lib, config, ... }:
{
  programs.zsh = {
    enable = true;
    autocd = true; # cdなしでファイルパスだけで移動
    enableCompletion = true; # 自動補完
    autosuggestion.enable = true; # 入力サジェスト
    syntaxHighlighting.enable = true; # シンタックスハイライト
    history = {
      ignorePatterns = [
        "fg *"
        "exit *"
        "export *API*"
        "history *"
        "exa"
        "ls"
        "cd"
      ];
      ignoreAllDups = true;
      share = true;
    };
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
        '';
        # $EDITOR=vim としているため、`;`や`Enter`にabbrの動作を割り当てるには
        # `-M emacs` オプションが必要になる。
        zshConfigLastInit = lib.mkOrder 1500 ''
          ABBR_SET_EXPANSION_CURSOR=1
          ABBR_SET_LINE_CURSOR=1
          compinit
          bindkey -e
          bindkey -M emacs ";" abbr-expand-and-insert
          bindkey -M emacs "Enter" abbr-expand-and-accept
          zstyle ':completion:*:default' menu select=1
          eval "$(direnv hook zsh)"
          export OPENROUTER_API_KEY=$(cat "/run/secrets/OPENROUTER_API_KEY")
          autoload -Uz run-help run-help-git run-help-ip run-help-sudo
          precmd() {
            # Mark end of previous command (no exit code here, since Zsh lacks easy last status in prompt):
            print -P "\e]133;D;\a"
          }
          PROMPT=$'%{\e]133;A\a%}'$PROMPT$'%{\e]133;B\a%}'
        '';
      in
      lib.mkMerge [
        zshConfigEarlyInit
        zshConfigLastInit
      ];
  };
}
