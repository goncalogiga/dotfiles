#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "📁 Dotfiles directory: $DOTFILES_DIR"

# --------------------------------------
# 1. System prerequisites
# --------------------------------------
if command -v apt >/dev/null; then
  echo "📦 Installing system dependencies"
  sudo apt update
  sudo apt install -y \
    curl \
    git \
    ca-certificates \
    xz-utils
fi

# --------------------------------------
# 2. Install Nix (if missing)
# --------------------------------------
if ! command -v nix >/dev/null; then
  echo "❄️ Installing Nix"
  sh <(curl -L https://nixos.org/nix/install) --daemon
else
  echo "✅ Nix already installed"
fi

# Load nix into current shell
if [ -e /etc/profile.d/nix.sh ]; then
  . /etc/profile.d/nix.sh
fi

# --------------------------------------
# 3. Enable flakes
# --------------------------------------
NIX_CONF="$HOME/.config/nix/nix.conf"
mkdir -p "$(dirname "$NIX_CONF")"

if ! grep -q flakes "$NIX_CONF" 2>/dev/null; then
  echo "⚙️ Enabling nix flakes"
  cat >>"$NIX_CONF" <<EOF
experimental-features = nix-command flakes
EOF
fi

# --------------------------------------
# 4. Link dotfiles
# --------------------------------------
echo "🔗 Linking dotfiles"

mkdir -p "$HOME/.config"

ln -sf "$DOTFILES_DIR/nvim"   "$HOME/.config/nvim"
ln -sf "$DOTFILES_DIR/kitty"  "$HOME/.config/kitty"
ln -sf "$DOTFILES_DIR/bash/.bashrc" "$HOME/.bashrc"

# --------------------------------------
# 5. Enter dev environment
# --------------------------------------
echo "🚀 Entering Nix dev shell"
cd "$DOTFILES_DIR/nix"
nix develop