#!/usr/bin/env bash
set -euo pipefail

# ==========================
# Configuration
# ==========================
REMOTE_USER="nixos"
REMOTE_PATH="/home/${REMOTE_USER}"
SSH_OPTS=(-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null)

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

# ==========================
# Remote Installer Logic
# ==========================
run_remote_installer() {
    local VM_IP="$1"
    local INSTALLER_SCRIPT="$2"
    local BOOT_MODE="$3"

    if [[ ! -f "$INSTALLER_SCRIPT" ]]; then
        echo "Error: $INSTALLER_SCRIPT not found"
        exit 1
    fi

    echo "==> Copying installer to VM (${VM_IP})..."
    scp "${SSH_OPTS[@]}" "$INSTALLER_SCRIPT" "${REMOTE_USER}@${VM_IP}:${REMOTE_PATH}/"

    echo "==> Connecting to VM and running installer..."
    ssh "${SSH_OPTS[@]}" "${REMOTE_USER}@${VM_IP}" "sudo bash ${REMOTE_PATH}/${INSTALLER_SCRIPT} ${BOOT_MODE}"
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
    [[ "$BOOT_MODE" == "uefi" ]] && mkfs.fat -F 32 -n "$BOOT_LABEL" "$BOOT_PART"
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
# NixOS Installation
# ==========================
generate_nixos_config() {
    log "Generating default NixOS configuration..."
    nixos-generate-config --root /mnt
}

clone_dotfiles() {
    log "Cloning dotfiles repository..."
    mkdir -p /mnt/root
    [[ -d "$DOTFILES_DIR/.git" ]] && rm -rf "$DOTFILES_DIR"
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
}

install_nixos() {
    log "Installing NixOS..."
    cp -r "$DOTFILES_DIR/nixos/" /mnt/etc/
    cp "$DOTFILES_DIR/flake.nix" /mnt/etc/nixos
    [[ -f "$DOTFILES_DIR/flake.lock" ]] && cp "$DOTFILES_DIR/flake.lock" /mnt/etc/nixos || INSTALL_FLAGS+=(--no-write-lock-file)
    cp -r "$DOTFILES_DIR/home" /mnt/etc/nixos/
    nixos-install "${INSTALL_FLAGS[@]}"
}

# ==========================
# Argument Validation
# ==========================
validate_args() {
    if [[ "$BOOT_MODE" != "uefi" && "$BOOT_MODE" != "legacy" ]]; then
        echo "Usage: $0 {uefi|legacy} [--skip-disks] | remote <VM_IP> <boot_mode>"
        exit 1
    fi
}

# ==========================
# Main
# ==========================
MODE="${1:-}"

if [[ "$MODE" == "remote" ]]; then
    VM_IP="${2:-}"
    BOOT_MODE="${3:-uefi}"
    run_remote_installer "$VM_IP" "$0" "$BOOT_MODE"
    exit 0
else
    BOOT_MODE="$1"
    SKIP_DISK_SETUP=false
    [[ "${2:-}" == "--skip-disks" ]] && SKIP_DISK_SETUP=true

    validate_args
    $SKIP_DISK_SETUP || { confirm_erase; partition_disk; format_partitions; mount_filesystems; generate_nixos_config; }
    clone_dotfiles
    install_nixos
    log "Rebooting..."
    reboot
fi