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

FLAKE_DIR="/mnt/etc/nixos"
FLAKE_TARGET="vm"
INSTALL_FLAGS=(--flake "${FLAKE_DIR}#${FLAKE_TARGET}")

BOOT_MODE="${1:-}"
SKIP_DISK_SETUP=false

if [[ "${2:-}" == "--skip-disks" ]]; then
    SKIP_DISK_SETUP=true
fi

# ==========================
# Helpers
# ==========================
log() {
    echo
    echo "==> $1"
    sleep 1
}

confirm_erase() {
    echo "WARNING: This will ERASE ALL DATA on ${DISK}"
    read -rp "Type 'YES' to continue: " CONFIRM
    [[ "$CONFIRM" == "YES" ]] || { echo "Aborted."; exit 1; }
}

validate_args() {
    if [[ "$BOOT_MODE" != "uefi" && "$BOOT_MODE" != "legacy" ]]; then
        echo "Usage: $0 {uefi|legacy} [--from-config]"
        exit 1
    fi
}

# ==========================
# Disk Setup
# ==========================
partition_disk() {
    log "Partitioning disk (${BOOT_MODE})..."

    if [[ "$BOOT_MODE" == "uefi" ]]; then
        parted "$DISK" -- mklabel gpt
        parted "$DISK" -- mkpart root ext4 512MB -"$SWAP_SIZE"
        parted "$DISK" -- mkpart swap linux-swap -"$SWAP_SIZE" 100%
        parted "$DISK" -- mkpart ESP fat32 1MB 512MB
        parted "$DISK" -- set 3 esp on

        ROOT_PART="${DISK}1"
        SWAP_PART="${DISK}2"
        BOOT_PART="${DISK}3"
    else
        parted "$DISK" -- mklabel msdos
        parted "$DISK" -- mkpart primary 1MB -"$SWAP_SIZE"
        parted "$DISK" -- set 1 boot on
        parted "$DISK" -- mkpart primary linux-swap -"$SWAP_SIZE" 100%

        ROOT_PART="${DISK}1"
        SWAP_PART="${DISK}2"
    fi
}

format_partitions() {
    log "Formatting partitions..."

    mkfs.ext4 -L "$ROOT_LABEL" "$ROOT_PART"
    mkswap -L "$SWAP_LABEL" "$SWAP_PART"

    if [[ "$BOOT_MODE" == "uefi" ]]; then
        mkfs.fat -F 32 -n "$BOOT_LABEL" "$BOOT_PART"
    fi
}

mount_filesystems() {
    log "Mounting filesystems..."

    mount "/dev/disk/by-label/${ROOT_LABEL}" /mnt

    if [[ "$BOOT_MODE" == "uefi" ]]; then
        mkdir -p /mnt/boot
        mount -o umask=077 "/dev/disk/by-label/${BOOT_LABEL}" /mnt/boot
    fi

    swapon "/dev/disk/by-label/${SWAP_LABEL}"
}

# ==========================
# NixOS Setup
# ==========================
generate_nixos_config() {
    log "Generating default NixOS configuration..."
    nixos-generate-config --root /mnt
}

clone_dotfiles() {
    log "Cloning dotfiles repository..."

    mkdir -p /mnt/root

    if [[ ! -d "$DOTFILES_DIR/.git" ]]; then
        git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
    else
        echo "Dotfiles already cloned, skipping."
    fi
}

install_nixos() {
    log "Installing NixOS..."

    cp "$DOTFILES_DIR/flake.nix" /mnt/etc/nixos/flake.nix

    if [[ -f "$DOTFILES_DIR/flake.lock" ]]; then
        cp "$DOTFILES_DIR/flake.lock" /mnt/etc/nixos/flake.lock
    else
        INSTALL_FLAGS+=(--no-write-lock-file)
    fi

    cp -r "$DOTFILES_DIR/nixos" /mnt/etc/nixos/

    nixos-install "${INSTALL_FLAGS[@]}"
}

# ==========================
# Main
# ==========================
validate_args

if ! $SKIP_DISK_SETUP; then
    confirm_erase
    partition_disk
    format_partitions
    mount_filesystems
    generate_nixos_config
else
    log "Skipping disk setup, starting from Nix configuration"
fi

clone_dotfiles
install_nixos

log "Rebooting..."
reboot