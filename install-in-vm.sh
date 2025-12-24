#!/usr/bin/env bash
set -euo pipefail

# ==========================
# Configuration
# ==========================
INSTALLER_SCRIPT="install.sh"
REMOTE_USER="nixos"
REMOTE_PATH="/home/${REMOTE_USER}"
BOOT_MODE="uefi"

SSH_OPTS=(
  -o StrictHostKeyChecking=no
  -o UserKnownHostsFile=/dev/null
)

# ==========================
# Validation
# ==========================
if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <VM_IP>"
  exit 1
fi

VM_IP="$1"

if [[ ! -f "$INSTALLER_SCRIPT" ]]; then
  echo "Error: $INSTALLER_SCRIPT not found in current directory"
  exit 1
fi

# ==========================
# Copy installer
# ==========================
echo "==> Copying installer to VM (${VM_IP})..."
scp "${SSH_OPTS[@]}" \
  "$INSTALLER_SCRIPT" \
  "${REMOTE_USER}@${VM_IP}:${REMOTE_PATH}/"

# ==========================
# Run installer remotely
# ==========================
echo "==> Connecting to VM and running installer..."
ssh "${SSH_OPTS[@]}" \
  "${REMOTE_USER}@${VM_IP}" \
  "sudo bash ${REMOTE_PATH}/${INSTALLER_SCRIPT} ${BOOT_MODE}"