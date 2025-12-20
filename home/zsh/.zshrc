# .zshrc - Hand-managed Zsh configuration
# Nix-managed paths are provided via environment variables

# ===== Load Nix-generated configuration first =====
# Nix が生成した .zshrc を読み込む（プラグインパスなどの設定が含まれる）
if [[ -f "$HOME/.config/zsh-nix/.zshrc" ]]; then
  echo '.zshrc loaded!'
  source "$HOME/.config/zsh-nix/.zshrc"
fi

# ===== Load user configuration =====
source ~/.config/zsh/env.zsh
source ~/.config/zsh/aliases.zsh
source ~/.config/zsh/functions.zsh
source ~/.config/zsh/keybindings.zsh
source ~/.config/zsh/completion.zsh
source ~/.config/zsh/zeno.zsh

# ===== Sheldon plugin manager =====
if command -v sheldon &> /dev/null; then
  eval "$(sheldon source)"
fi
