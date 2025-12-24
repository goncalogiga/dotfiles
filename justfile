# Justfile to manage NixOS installation

# --- Variables ---

# In what boot mode should the VM be setup in (either uefi or legacy)
boot_mode := {{ env_var_or_default("VM_BOOT_MODE", "uefi") }}


# --- Recepies ---

# Setup NixOS on the VM
setup-vm vm_ip:
    @echo "Installing NixOS on remote VM ${vm_ip} in ${boot_mode} mode..."
    bash nix.sh remote {{vm_ip}} {{boot_mode}}