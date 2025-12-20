# dotfiles

This repository contains my NixOS + Home Manager configuration

## Setting up the NixOS VM on macOS

I use **UTM** to run a NixOS VM. The following steps will guide you through setting it up.

### 1. Prerequisites on macOS

1. Install **UTM** from [https://mac.getutm.app](https://mac.getutm.app)
2. Optionally install `qemu` if you want to manipulate disk images:
   ```bash
   brew install qemu
   ```
3. Download the **NixOS graphical ISO** for your architecture:
   - Apple Silicon → ARM64
   - Intel → x86_64
   [Download here](https://nixos.org/download.html)

---

### 2. Create a new VM in UTM

1. Open UTM → **+ New VM** → Virtualize → Linux → select architecture
2. Attach the **NixOS ISO** you downloaded
3. Allocate **CPU & Memory**
4. Add **storage**
5. Configure **display** → SPICE/virtio + GPU acceleration
6. Configure **networking** → Shared Network or Bridged
7. Finish and boot the VM

---

### 3. Install NixOS inside the VM

1. Open the terminal in the live ISO
2. Partition and format your disk:
   ```bash
   parted /dev/vda mklabel gpt
   parted /dev/vda mkpart primary 512MiB 100%
   parted /dev/vda set 1 boot on
   mkfs.ext4 /dev/vda1
   mount /dev/vda1 /mnt
   ```
3. Generate a default NixOS configuration:
   ```bash
   nixos-generate-config --root /mnt
   ```
4. Clone this dotfiles repository into the VM:
   ```bash
   git clone https://github.com/goncalogiga/dotfiles.git /mnt/root/dotfiles
   ```
5. Replace the generated configuration with your flake-based config:
   ```bash
   mv /mnt/etc/nixos/configuration.nix /mnt/etc/nixos/configuration.nix.backup
   ln -s /mnt/root/dotfiles/nixos/configuration.nix /mnt/etc/nixos/configuration.nix
   ```
6. Install NixOS:
   ```bash
   nixos-install
   reboot
   ```

---

### 4. Apply Home Manager configuration

After reboot, log in and enable Nix flakes:

```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

Then apply Home Manager (Bash, Neovim, Python, direnv, etc.):

```bash
nix run home-manager/master -- switch --flake /root/dotfiles#vm
```

---

### 5. Prebuilt VM image

If you want to reuse this VM or distribute it:

1. Shut down the VM
2. Convert the disk to a QCOW2 image:

```bash
qemu-img convert -O qcow2 /path/to/vm_disk.img nixos-vm.qcow2
```

3. In UTM → **Import Existing Disk Image** → select `nixos-vm.qcow2`

Your VM will boot fully configured.

---

### 6. Updating your VM

To pull the latest dotfiles and apply updates:

```bash
cd /root/dotfiles
git pull
nix run home-manager/master -- switch --flake /root/dotfiles#vm
```

This will update all tools, dotfiles, and environments reproducibly.

---

### 7. Useful shortcuts

- Open Kitty terminal: `kitty`
- Start Docker: `sudo systemctl start docker`
- Enter Python project environment: `cd /path/to/project && direnv allow`

---