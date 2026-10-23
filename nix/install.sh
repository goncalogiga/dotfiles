# Installs the `utm` NixOS configuration on /dev/vda, from the NixOS live ISO.
# Wrapped by flake.nix (apps.install), which provides $DISKO and git.
# Usage: install-utm [branch]

repo="https://github.com/goncalogiga/dotfiles"
branch="${1:-main}"
dest="/mnt/home/goncalo/dotfiles"
export NIX_CONFIG="experimental-features = nix-command flakes"

if [ "$(id -u)" -ne 0 ]; then
    echo "install: must run as root (sudo)" >&2
    exit 1
fi

# Partition, format and mount on /mnt (asks for confirmation before wiping)
"$DISKO"

# The system is built from a real clone, which becomes ~/dotfiles
git clone --branch "$branch" "$repo" "$dest"
nixos-install --flake "$dest/nix#utm" --no-root-passwd
chown -R 1000:100 /mnt/home/goncalo

cat <<'EOF'

Installation complete.
- Shut down, remove the ISO from the UTM drive, and boot again.
- Log in as `goncalo` with password `nixos`, then run `passwd`.
EOF
