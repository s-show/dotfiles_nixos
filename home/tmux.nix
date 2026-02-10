{ pkgs, ... }:
let
  # tmux-menus plugin definition
  # let ブロックで定義すると ${tmux-menus} でインストールパスを取得できる
  tmux-menus = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tmux-menus";
    rtpFilePath = "menus.tmux";
    version = "v2.2.33";
    src = pkgs.fetchFromGitHub {
      owner = "jaclu";
      repo = "tmux-menus";
      rev = "879f56df1b9703ac277fa16b9bbaf8705f2e6a1c";
      hash = "sha256-UPWsa7sFy6P3Jo3KFEvZrz4M4IVDhKI7T1LNAtWqTT4=";
    };
  };
in
{
  programs.tmux = {
    enable = true;
    mouse = true;
    escapeTime = 0;
    clock24 = true;
    keyMode = "vi";
    historyLimit = 20000;
    baseIndex = 1;
    extraConfig = ''
      # status-left の表示長を拡張（日時 + mode-indicator を表示するため）
      set -g status-left-length 40
      set -g status-right-length 100

      # スクロールアップするとコピーモードに入る
      bind-key -n WheelUpPane if-shell -F -t = "#{mouse_any_flag}" "send-keys -M" "if -Ft= '#{pane_in_mode}' 'send-keys -M' 'select-pane -t=; copy-mode -e; send-keys -M'"

      # 最後までスクロールダウンするとコピーモードを抜ける
      bind-key -n WheelDownPane select-pane -t= \; send-keys -M

      # 境界線の種類を変更（single, double, heavy, simple, number から選択）
      set -g pane-border-lines heavy

      # 非アクティブなペイン（colour235 と colour247 を使用）
      set -g window-style 'fg=#bcbcbc,bg=#333333'

      # ステータスバーを透明化する
      set -g status-style bg=default

      # ベルが鳴ったウィンドウのウィンドウ名の左にベルマークを表示
      set-option -g monitor-bell on
      set-option -gw window-status-bell-style "bold"
      set-option -gw window-status-format '#(if [ "#{window_bell_flag}" = "1" ]; then
        echo " 󱅫 #{window_index} #{window_name} "; else echo "#{window_index} #{window_name} ";
      fi)'
      
      # set -g @status-left "\
      # #{?client_prefix,PREFIX ,\
      # #{?pane_in_mode,COPY ,\
      # #{?pane_synchronized,SYNC ,TMUX \
      # }}}\
      # [#S]"

      # クリップボードを有効化
      set -g set-clipboard on

      # ウィンドウ番号を自動リナンバー（削除時に詰める）
      set -g renumber-windows on

      # 分割時に現在のパスを引き継ぐ
      bind v split-window -h -c "#{pane_current_path}"
      bind | split-window -h -c "#{pane_current_path}"
      bind s split-window -v -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # Alt-i で pane 選択のインデックスを表示
      bind-key -n M-i display-panes
    '';
    plugins = with pkgs; [
      {
        plugin = tmuxPlugins.tmux-nova;
        extraConfig = ''
          ### THEME ###
          set -g @nova-nerdfonts true
          set -g @nova-nerdfonts-left 
          set -g @nova-nerdfonts-right 

          set -g @nova-pane "#I #W"
          set -g @nova-rows 0

          ### COLORS ###
          b_bg="#504945"
          seg_a="#a89984 #282828"
          seg_b="$b_bg #ddc7a1"
          inactive_bg="#32302f"
          inactive_fg="#ebdbb2"
          active_bg="#fabd2f"
          active_fg="#3c3836"

          set -gw window-status-current-style bold
          set -g "@nova-status-style-bg" "$inactive_bg"
          set -g "@nova-status-style-fg" "$inactive_fg"
          set -g "@nova-status-style-active-bg" "$active_bg"
          set -g "@nova-status-style-active-fg" "$active_fg"
          set -g "@nova-pane-active-border-style" "#44475a"
          set -g "@nova-pane-border-style" "#827d51"

          ### STATUS BAR ###
          set -g @nova-segment-prefix ["\
          #{?client_prefix,PREFIX ,\
          #{?#{m:copy-mode,#{pane_mode}},COPY ,\
          #{?#{m:tree-mode,#{pane_mode}},TREE ,\
          #{?#{pane_in_mode},SELECT ,\
          #{?pane_synchronized,SYNC ,TMUX \
          }}}}}}]\
          [#S]"
          set -g @nova-segment-prefix-colors "$seg_b"
          set -g @nova-segment-session "#{session_name}"
          set -g @nova-segment-session-colors "$seg_a"
          set -g @nova-segment-whoami "#(whoami)@#h"
          set -g @nova-segment-whoami-colors "$seg_a"
          set -g @nova-segment-continuum "Continuum status: #{continuum_status}"
          set -g @nova-segments-0-left "prefix session"
          set -g @nova-segments-0-right "continuum whoami"

          ### WINDOW BAR ###
          set -g @nova-pane "#I   #W"
        '';
      }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '3' # minutes
        '';
      }
      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = "set -g @resurrect-strategy-nvim 'session'";
      }
      {
        plugin = tmuxPlugins.tmux-which-key;
        extraConfig = ''
          set -g @tmux-which-key-xdg-enable 1
          set -g @tmux-which-key-disable-autobuild 1
        '';
      }
      {
        plugin = tmuxPlugins.tmux-fzf;
        extraConfig = ''
          TMUX_FZF_LAUNCH_KEY="M-f"
        '';
      }
      {
        plugin = tmux-menus;
        extraConfig = ''
          set -g @plugin 'jaclu/tmux-menus'
          set -g @menus_use_cache 'No'
        '';
      }
    ];
  };
}
