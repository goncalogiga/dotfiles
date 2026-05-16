#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v brew >/dev/null; then
    echo "Error: Homebrew is required. Install it from https://brew.sh" >&2
    exit 1
fi

# Install neovim if missing
if ! command -v nvim >/dev/null; then
    brew install --HEAD neovim
fi

# Install kitty if missing
if ! command -v kitty >/dev/null; then
    brew install --cask kitty
fi

# Install tree-sitter if missing
if ! command -v tree-sitter >/dev/null; then
    brew install tree-sitter
    brew install tree-sitter-cli
fi

# Install lazygit if missing
if ! command -v lazygit >/dev/null; then
    brew install lazygit
fi

# Install fzf and fd if missing (needed for cdf alias)
if ! command -v fzf >/dev/null; then
    brew install fzf
fi

if ! command -v fd >/dev/null; then
    brew install fd
fi

# Install uv if missing
if ! command -v uv >/dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# Install node and npm if missing
if ! command -v node >/dev/null; then
    brew install node
fi

# Link dotfiles
mkdir -p "$HOME/.config"

ln -sf "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
ln -sf "$DOTFILES_DIR/kitty" "$HOME/.config/kitty"

# Link shell configs
ln -sf "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/bash/.bashrc" "$HOME/.bashrc"

# Set zsh as default shell if it isn't already
if [ "$SHELL" != "$(command -v zsh)" ]; then
    if command -v zsh >/dev/null; then
        chsh -s "$(command -v zsh)"
        echo "Default shell set to zsh. Re-login for it to take effect."
    else
        echo "zsh not found — install it with: brew install zsh"
    fi
fi
