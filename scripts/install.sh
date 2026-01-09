#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# System packages
if command -v apt >/dev/null; then
  sudo apt update
  sudo apt install -y \
    curl \
    git \
    ca-certificates \
    xz-utils \
    kitty \
    fontconfig
fi

# Install JetBrains Mono Nerd Font (system-wide)
FONT_DIR="/usr/local/share/fonts/JetBrainsMonoNerdFont"

if [ ! -d "$FONT_DIR" ]; then
  sudo mkdir -p "$FONT_DIR"
  curl -L https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip \
    -o /tmp/JetBrainsMono.zip
  sudo unzip /tmp/JetBrainsMono.zip -d "$FONT_DIR"
  sudo fc-cache -fv
fi

# Install Nix
if ! command -v nix >/dev/null; then
  sh <(curl -L https://nixos.org/nix/install) --daemon
fi

# Load nix
if [ -e /etc/profile.d/nix.sh ]; then
  . /etc/profile.d/nix.sh
fi

# Enable flakes
NIX_CONF="$HOME/.config/nix/nix.conf"
mkdir -p "$(dirname "$NIX_CONF")"

if ! grep -q "flakes" "$NIX_CONF" 2>/dev/null; then
  echo "experimental-features = nix-command flakes" >>"$NIX_CONF"
fi

# Link dotfiles
mkdir -p "$HOME/.config"

ln -sf "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
ln -sf "$DOTFILES_DIR/kitty" "$HOME/.config/kitty"
ln -sf "$DOTFILES_DIR/bash/.bashrc" "$HOME/.bashrc"

# Setup linux preferences
bash linux/ubuntu_preferences.sh

# Final notice
cat <<'EOF'

Installation complete.

Important:
- Fully close and reopen your terminal for font changes to take effect.
- Run `dev` to enter the nix common development environment.

EOF