# dotfiles

This repository contains my NixOS + Home Manager configuration

## Setting up the NixOS VM on macOS

I use **UTM** to run a NixOS VM. The following steps will guide you through setting it up.

### 1. Prerequisites on macOS

1. Install **UTM** from [https://mac.getutm.app](https://mac.getutm.app)
2. Download the **NixOS minimal ISO** from [https://nixos.org/download/](https://nixos.org/download/) (choose ARM64 for Apple Silicon compatibility)

---

### 2. Create a new VM in UTM

1. Open UTM → **+ New VM** → Virtualize → Linux
2. Allocate **CPU & Memory**
3. Select **boot ISO image** and choose the downloaded NixOS iso file
4. Add **storage**
5. Setup shared directory (TODO)
6. Rename the VM (optional but cool)
7. Boot the VM
8. Select the GNOME Linux LTS installer

> Personnal note : VM with 8192MiB memory, 8 CPU cores, 64GB storage does the job.

---

### 3. Setup NixOS inside the VM

#### Semi-automatic setup

1. Run `passwd` and add a dummy password.
2. Get the local IP of the VM using `hostname -I`.
3. Run `bash install-in-vm.sh <VM_IP>`.

#### Manuel setup

1. Run `passwd` and add a dummy password.
2. Get the local IP of the VM using `hostname -I`.
3. Use `ssh -o StrictHostKeychecking=no nixos@<VM_IP>` to SSH into the VM for simplicity.
4. Run `sudo su` so we can partition and format the visrtual disk.
5. Partition the disk according to the [Nix documentation](https://nixos.org/manual/nixos/stable/#sec-installation-manual-partitioning-UEFI) (Note that disk will likely be `/dev/vda` and not `/dev/sda`.)
6. Format the disk according to the [Nix documentation](https://nixos.org/manual/nixos/stable/#sec-installation-manual-partitioning-formatting) (Note that disk will likely be `/dev/vda*` and not `/dev/sda*`.)
7. Mount and generate an initial config according to the [Nix documentation](https://nixos.org/manual/nixos/stable/#sec-installation-manual-partitioning-formatting) (Note that swapn will likely target `/dev/vda2` and not `/dev/sda2`.)
8. We can now git clone our NixOS configuration : `git clone https://github.com/goncalogiga/dotfiles.git /mnt/root/dotfiles`.
9. Replace the generated config with ours : `cp /mnt/root/dotfiles/flake.nix /mnt/etc/nixos/flake.nix && cp -r /mnt/root/dotfiles/nixos" /mnt/etc/nixos/`.
10. Install NixOS and reboot : `nixos-install && reboot`

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