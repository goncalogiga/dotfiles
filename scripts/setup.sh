#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SECRETS_DIR="$DOTFILES_DIR/decrypted/"

# System packages
if command -v apt >/dev/null; then
  sudo apt update
  sudo apt install -y \
    curl \
    git \
    ca-certificates \
    xz-utils \
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
cp "$DOTFILES_DIR/bash/.bashrc" "$HOME/.bashrc"

# Export DOTFILES_PATH to bashrc and zshrc
export_line="export DOTFILES_PATH=\"$DOTFILES_DIR\""
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$rc" ] && ! grep -qF "DOTFILES_PATH" "$rc"; then
        echo "$export_line" >> "$rc"
    fi
done

# Setup linux preferences
bash linux/ubuntu_preferences.sh

# Decrypt secrets
just decrypt || echo "Warning: 'just decrypt' failed, skipping secrets."

# Correctly setup encryption checks (pre-commit hooks)
just setup-hooks

# Add python virtual environment
python3 -m venv .venv
source .venv/bin/activate
pip install pyright pynvim black isort
deactivate

# Link ssh 
ln -sf "$SECRETS_DIR/ssh/id_ed25519" "$HOME/.ssh/id_ed25519"
ln -sf "$SECRETS_DIR/ssh/id_ed25519.pub" "$HOME/.ssh/id_ed25519.pub"
ln -sf "$SECRETS_DIR/ssh/known_hosts" "$HOME/.ssh/known_hosts"

# Install and setup docker
bash scripts/docker.sh

# Final notice
cat <<'EOF'

Installation complete.

Important:
- Fully close and reopen your terminal for font changes to take effect.
- Run `dev` to enter the nix common development environment.
- In order for docker to be fully functionnal, you must restart the VM.

EOF
