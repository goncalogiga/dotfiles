#!/usr/bin/env bash
set -euo pipefail
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v brew >/dev/null; then
    echo "Error: Homebrew is required. Install it from https://brew.sh" >&2
    exit 1
fi

# Install neovim if missing
if ! command -v nvim >/dev/null; then
    brew install neovim
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
if ! command -v ripgrep >/dev/null; then
    brew install ripgrep
fi

# Install uv if missing
if ! command -v uv >/dev/null; then
    brew install uv
fi

# Install node and npm if missing
if ! command -v node >/dev/null; then
    brew install node
fi

# Install btop if missing
if ! command -v btop >/dev/null; then
    brew install btop
fi

# Install coreutils if missing (GNU ls/dircolors for linux-matching colours)
if ! command -v gls >/dev/null; then
    brew install coreutils
fi

# Install Docker Sandboxes (sbx) if missing — Apple silicon only
if ! command -v sbx >/dev/null; then
    if [ "$(uname -m)" = "arm64" ]; then
        brew trust docker/tap
        brew install docker/tap/sbx
    else
        echo "Skipping sbx: requires Apple silicon" >&2
    fi
fi

# Install Karabiner-Elements if missing
if ! [ -d "/Applications/Karabiner-Elements.app" ]; then
    brew install --cask karabiner-elements
fi

# Link Karabiner config
KARABINER_DIR="$HOME/.config/karabiner/assets/complex_modifications"
mkdir -p "$KARABINER_DIR"
ln -sf "$DOTFILES_DIR/karabiner/pc_shortcuts.json" "$KARABINER_DIR/pc_shortcuts.json"

# Link dotfiles
mkdir -p "$HOME/.config"
ln -sf "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
ln -sf "$DOTFILES_DIR/kitty" "$HOME/.config/kitty"

# Link shell configs
cp "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
cp "$DOTFILES_DIR/bash/.bashrc" "$HOME/.bashrc"

# Shared neovim python environment
NVIM_VENV="${XDG_CACHE_HOME:-$HOME/.cache}/nvim-venv"
uv venv "$NVIM_VENV"
VIRTUAL_ENV="$NVIM_VENV" uv pip install pynvim black isort

# Python-based CLI tools, installed as isolated executables
uv tool install pyright

# Export DOTFILES_PATH to bashrc and zshrc
export_line="export DOTFILES_PATH=\"$DOTFILES_DIR\""
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$rc" ] && ! grep -qF "DOTFILES_PATH" "$rc"; then
        echo "$export_line" >> "$rc"
    fi
done
