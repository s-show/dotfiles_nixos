# completion.zsh - Completion configuration

# zsh-abbr expansion cursor settings
# ABBR_SET_EXPANSION_CURSOR=1
# ABBR_SET_LINE_CURSOR=1

# Completion initialization (called again for custom settings)
compinit

# Completion styles
zstyle ':completion:*:default' menu select=1
zstyle ':completion:*:default' ignore-parents parent pwd ..

# Add custom completion paths
fpath+="$HOME/.local/bin/"
