#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Configuration
# ============================================================

REMOTE_USER="nixos"
REMOTE_HOME="/home/${REMOTE_USER}"
SSH_OPTS=(
    -o StrictHostKeyChecking=no
    -o UserKnownHostsFile=/dev/null
)

DISK="/dev/vda"
SWAP_SIZE="8GB"

ROOT_LABEL="nixos"
SWAP_LABEL="swap"
BOOT_LABEL="boot"

DOTFILES_REPO="https://github.com/goncalogiga/dotfiles.git"
DOTFILES_DIR="dotfiles"

FLAKE_DIR="$PWD/$DOTFILES_DIR"
FLAKE_TARGET="vm"

# ============================================================
# Logging & helpers
# ============================================================

log() {
    echo
    echo "==> $1"
}

fatal() {
    echo "Error: $1" >&2
    exit 1
}

confirm_disk_erase() {
    echo
    echo "WARNING: This will ERASE ALL DATA on ${DISK}"
    read -rp "Type 'YES' to continue: " answer
    [[ "$answer" == "YES" ]] || fatal "Aborted by user"
}

# ============================================================
# CLI parsing
# ============================================================

COMMAND=""
FROM=""
BOOT_MODE=""
SKIP_VM_SETUP=false

parse_args() {
    [[ $# -ge 1 ]] || fatal "No command specified"

    COMMAND="$1"
    shift

    while [[ $# -gt 0 ]]; do
        case "$1" in
        --from)
            FROM="$2"
            shift 2
            ;;
        --boot-mode)
            BOOT_MODE="$2"
            shift 2
            ;;
        --skip-vm-setup)
            SKIP_VM_SETUP=true
            shift
            ;;
        *)
            fatal "Unknown argument: $1"
            ;;
        esac
    done
}

validate_args() {
    [[ "$COMMAND" == "setup" ]] || fatal "Unknown command: $COMMAND"
    [[ -n "$FROM" ]]       || fatal "--from is required"
    [[ -n "$BOOT_MODE" ]] || fatal "--boot-mode is required"

    case "$BOOT_MODE" in
        uefi|legacy) ;;
        *) fatal "--boot-mode must be 'uefi' or 'legacy'" ;;
    esac
}

# ============================================================
# Remote execution
# ============================================================

run_remote_setup() {
    local vm_ip="$1"

    log "Copying installer to ${vm_ip}"
    scp "${SSH_OPTS[@]}" "$0" "${REMOTE_USER}@${vm_ip}:${REMOTE_HOME}/nix.sh"

    log "Running installer remotely"
    ssh "${SSH_OPTS[@]}" "${REMOTE_USER}@${vm_ip}" \
        "sudo bash ${REMOTE_HOME}/nix.sh setup \
        --from local \
        --boot-mode ${BOOT_MODE}"
}

# ============================================================
# Disk & filesystem setup
# ============================================================

partition_disk() {
    log "Partitioning disk (${BOOT_MODE})"

    if [[ "$BOOT_MODE" == "uefi" ]]; then
        parted "$DISK" -- mklabel gpt
        parted "$DISK" -- mkpart ESP fat32 1MB 512MB
        parted "$DISK" -- set 1 esp on
        parted "$DISK" -- mkpart root ext4 512MB -"$SWAP_SIZE"
        parted "$DISK" -- mkpart swap linux-swap -"$SWAP_SIZE" 100%

        BOOT_PART="${DISK}1"
        ROOT_PART="${DISK}2"
        SWAP_PART="${DISK}3"
    else
        parted "$DISK" -- mklabel msdos
        parted "$DISK" -- mkpart primary ext4 1MB -"$SWAP_SIZE"
        parted "$DISK" -- set 1 boot on
        parted "$DISK" -- mkpart primary linux-swap -"$SWAP_SIZE" 100%

        ROOT_PART="${DISK}1"
        SWAP_PART="${DISK}2"
    fi
}

format_partitions() {
    log "Formatting partitions"

    mkfs.ext4 -L "$ROOT_LABEL" "$ROOT_PART"
    mkswap    -L "$SWAP_LABEL" "$SWAP_PART"

    if [[ "$BOOT_MODE" == "uefi" ]]; then
        mkfs.fat -F 32 -n "$BOOT_LABEL" "$BOOT_PART"
    fi
}

mount_filesystems() {
    sleep 1 # Let's wait a bit before mounting to avoid any weird stuff
    log "Mounting filesystems"

    mount "/dev/disk/by-label/${ROOT_LABEL}" /mnt

    if [[ "$BOOT_MODE" == "uefi" ]]; then
        mkdir -p /mnt/boot
        mount -o umask=077 "/dev/disk/by-label/${BOOT_LABEL}" /mnt/boot
    fi

    swapon "/dev/disk/by-label/${SWAP_LABEL}"
}

# ============================================================
# NixOS installation
# ============================================================

generate_base_config() {
    log "Generating hardware configuration"
    nixos-generate-config --root /mnt
}

clone_dotfiles() {
    log "Cloning dotfiles"

    sudo rm -rf "$DOTFILES_DIR"
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
}

install_nixos() {
    log "Installing NixOS"

    # TODO : remove this once we have a flake.lock
    local install_args=(--flake "${FLAKE_DIR}#${FLAKE_TARGET}")
    if [[ ! -f "$DOTFILES_DIR/flake.lock" ]]; then
        install_args+=(--no-write-lock-file)
    fi

    nixos-install "${install_args[@]}"
}

# ============================================================

main() {
    parse_args "$@"
    validate_args

    if [[ "$FROM" != "local" ]]; then
        run_remote_setup "$FROM"
        exit 0
    fi

    if [[ "$SKIP_VM_SETUP" != "true" ]]; then
        confirm_disk_erase
        partition_disk
        format_partitions
        mount_filesystems
        generate_base_config
    fi
    
    clone_dotfiles
    install_nixos

    echo "Everything's good ! If you are using UTM, stop the ssh connection and clear the boot ISO image before rebooting the system."
}

main "$@"