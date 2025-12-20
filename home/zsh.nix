{ pkgs, lib, config, ... }:
let
  # wsl-notify-send パッケージをインポート
  wsl-notify-send = import ./packages/wsl-notify-send.nix { inherit pkgs lib; };
in
{
  programs.zsh = {
    enable = true;
    autocd = true;
    enableCompletion = true; # 自動補完
    autosuggestion.enable = true; # 入力サジェスト
    # syntaxHighlighting.enable = true; # シンタックスハイライト
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

    # カスタム設定を追加
    initExtra = ''
      # Sheldon plugin manager
      if command -v sheldon &> /dev/null; then
        eval "$(sheldon source)"
      fi

      source ~/.config/zsh/env.zsh
      source ~/.config/zsh/aliases.zsh
      source ~/.config/zsh/functions.zsh
      source ~/.config/zsh/keybindings.zsh
      source ~/.config/zsh/completion.zsh
      source ~/.config/zsh/zeno.zsh
    '';
  };

  # Nix が管理するパスを環境変数として渡す
  home.sessionVariables = {
    WSL_NOTIFY_SEND = "${wsl-notify-send}/bin/wsl-notify-send.exe";
  };
}
