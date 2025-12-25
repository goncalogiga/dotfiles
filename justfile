# Justfile to manage NixOS installation

# --- Variables ---

# In what boot mode should the VM be setup in (either uefi or legacy)
boot_mode := env_var_or_default("VM_BOOT_MODE", "uefi")

# --- Recipes ---

# Setup NixOS on the VM
setup vm_ip:
    @echo "Setting-up NixOS on remote VM {{vm_ip}} in {{boot_mode}} mode..."
    bash nix.sh setup --from {{vm_ip}} --boot-mode {{boot_mode}}

# Update installer with local changes
update-installer vm_ip:
    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null nix.sh nixos@{{vm_ip}}:/home/nixos/nix.sh

# SSH to the VM
ssh-vm vm_ip:
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null nixos@{{vm_ip}}

# Local installation (inside the VM)
nixos-install:
    @echo "Running NixOS installation in {{boot_mode}} mode..."
    bash nix.sh setup --from local --boot-mode {{boot_mode}} --skip-vm-setup