#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ "$DOTFILES_DIR" != "$HOME/dotfiles" ]; then
  echo "Error: clone this repo to ~/dotfiles, nix/home.nix expects it there" >&2
  exit 1
fi

# System packages. kitty comes from apt: nix GUI apps need extra OpenGL setup
# outside NixOS
sudo apt update
sudo apt install -y \
  curl \
  git \
  ca-certificates \
  xz-utils \
  fontconfig \
  kitty

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

# Older versions of this script symlinked whole config dirs into the repo,
# home-manager would then write its files inside ~/dotfiles
for dir in nvim kitty; do
  if [ -L "$HOME/.config/$dir" ]; then
    rm "$HOME/.config/$dir"
  fi
done

# Packages, font, dotfiles and the neovim python environment (nix/home-linux.nix).
# Files already in the way are renamed to *.bak
nix run --inputs-from "$DOTFILES_DIR/nix" home-manager -- \
  switch -b bak --flake "$DOTFILES_DIR/nix#goncalo-$(uname -m)"

# Install and setup docker
bash "$DOTFILES_DIR/scripts/docker.sh"

# Final notice
cat <<'EOF'

Installation complete.

Important:
- Log out and back in (or reboot) for the font, the PATH and the docker group
  to take effect.
- Apply later changes to nix/ with `rebuild`.

EOF
