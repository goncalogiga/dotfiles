#!/usr/bin/env bash
set -euo pipefail

# ==========================
# Configuration
# ==========================
DISK="/dev/vda"
SWAP_SIZE="8GB"

ROOT_LABEL="nixos"
SWAP_LABEL="swap"
BOOT_LABEL="boot"

DOTFILES_REPO="https://github.com/goncalogiga/dotfiles.git"
DOTFILES_DIR="/mnt/root/dotfiles"

BOOT_MODE="${1:-}"

# ==========================
# Validation
# ==========================
if [[ "$BOOT_MODE" != "uefi" && "$BOOT_MODE" != "legacy" ]]; then
  echo "Usage: $0 {uefi|legacy}"
  exit 1
fi

echo "⚠️  WARNING: This will ERASE ALL DATA on ${DISK}"
read -rp "Type 'YES' to continue: " CONFIRM
if [[ "$CONFIRM" != "YES" ]]; then
  echo "Aborted."
  exit 1
fi

echo
echo "==> Partitioning disk (${BOOT_MODE})..."
sleep 1

# ==========================
# Partitioning
# ==========================
if [[ "$BOOT_MODE" == "uefi" ]]; then
  parted "$DISK" -- mklabel gpt
  sleep 1

  parted "$DISK" -- mkpart root ext4 512MB -"$SWAP_SIZE"
  sleep 1

  parted "$DISK" -- mkpart swap linux-swap -"$SWAP_SIZE" 100%
  sleep 1

  parted "$DISK" -- mkpart ESP fat32 1MB 512MB
  parted "$DISK" -- set 3 esp on
  sleep 1

  ROOT_PART="${DISK}1"
  SWAP_PART="${DISK}2"
  BOOT_PART="${DISK}3"
else
  parted "$DISK" -- mklabel msdos
  sleep 1

  parted "$DISK" -- mkpart primary 1MB -"$SWAP_SIZE"
  parted "$DISK" -- set 1 boot on
  sleep 1

  parted "$DISK" -- mkpart primary linux-swap -"$SWAP_SIZE" 100%
  sleep 1

  ROOT_PART="${DISK}1"
  SWAP_PART="${DISK}2"
fi

echo
echo "==> Formatting partitions..."
sleep 1

# ==========================
# Formatting
# ==========================
mkfs.ext4 -L "$ROOT_LABEL" "$ROOT_PART"
sleep 2

mkswap -L "$SWAP_LABEL" "$SWAP_PART"
sleep 1

if [[ "$BOOT_MODE" == "uefi" ]]; then
  mkfs.fat -F 32 -n "$BOOT_LABEL" "$BOOT_PART"
  sleep 1
fi

echo
echo "==> Mounting filesystems..."
sleep 1

# ==========================
# Mounting
# ==========================
mount "/dev/disk/by-label/${ROOT_LABEL}" /mnt
sleep 1

if [[ "$BOOT_MODE" == "uefi" ]]; then
  mkdir -p /mnt/boot
  mount -o umask=077 "/dev/disk/by-label/${BOOT_LABEL}" /mnt/boot
  sleep 1
fi

swapon "$SWAP_PART"
sleep 1

echo
echo "==> Generating default NixOS configuration..."
sleep 1

# ==========================
# NixOS setup
# ==========================
nixos-generate-config --root /mnt
sleep 1

echo
echo "==> Cloning dotfiles repository..."
sleep 1

mkdir -p /mnt/root
git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
sleep 1

echo
echo "==> Replacing configuration.nix with flake-based config..."
sleep 1

mv /mnt/etc/nixos/configuration.nix \
   /mnt/etc/nixos/configuration.nix.backup

ln -s \
  /mnt/root/dotfiles/nixos/configuration.nix \
  /mnt/etc/nixos/configuration.nix

sleep 1

echo
echo "==> Installing NixOS..."
sleep 2

nixos-install
sleep 3

echo
echo "==> Rebooting..."
sleep 3

reboot