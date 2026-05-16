# dotfiles

This repository contains my development setup accross platforms.

## MacOS

MacOS setup does not use nix since it's not so important to have strict reproducability. The only stuff required to get going is `kitty`, `neovim`, `lazygit`, `uv` and `fzf`. The rest (like docker and stuff) is left to manual installation.

We can setup the base neovim development environment with : 

```bash
just macos-setup
```

## Ubuntu VM on macOS

I use **UTM** to run a Ubuntu VM. The following steps will guide you through setting it up.

### 1. Prerequisites on macOS

1. Install **UTM** from [https://mac.getutm.app](https://mac.getutm.app).
2. Download the Ubuntu 25.04 ARM64 ISO from the [https://cdimage.ubuntu.com/releases/25.04/release/](Ubuntu website).

---

### 2. Create a new VM in UTM

1. Open UTM → **+ New VM** → Virtualize → Linux
2. Allocate **CPU & Memory**
3. Check the `Enable hardware OpenGL acceleration` box.
4. Check the `Use Apple Virtualization` box
5. Select **boot ISO image** and choose the downloaded Ubuntu ISO file
6. Add **storage**
7. Setup shared directory (Optional)
8. Rename the VM
9. Boot the VM
10. Select the `Try or Install Ubuntu` line.
11. Follow the installer guide and install Ubuntu on the VM.

> Personnal note : VM with 8192MiB memory, default CPU cores, 64GB storage does the job.

---

### 3. Setup Nix inside the VM

1. Simply run `just install` to install Nix, as well as the environnement specified by the Flake.
2. After the script, you should found yourself inside the working development environment.

---

## Ubuntu

There is no real difference between a native Ubuntu instance and a VM. Therefore, we can use `nix` again to set everything up : 

```bash
sudo apt-get install git just
# Clone the repository and run : 
just install
```
