# env.zsh - Environment variables and exports

# Editor
export EDITOR=nvim

# API Keys (from SOPS secrets)
export OPENROUTER_API_KEY=$(cat "/run/secrets/OPENROUTER_API_KEY")
export OPENAI_API_KEY=$(cat "/run/secrets/OPENAI_API_KEY")
export CEREBRAS_API_KEY=$(cat "/run/secrets/CEREBRAS_API_KEY")
export GEMINI_API_KEY=$(cat "/run/secrets/GEMINI_API_KEY")
export BRAVE_SEARCH_API_KEY=$(cat "/run/secrets/BRAVE_SEARCH_API_KEY")
export GITHUB_MCP_PAT=$(cat "/run/secrets/GITHUB_MCP_PAT")
