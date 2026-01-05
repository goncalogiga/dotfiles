# dotfiles

This repository contains my development setup accross platforms.

## Ubuntu VM on macOS

I use **UTM** to run a Ubuntu VM. The following steps will guide you through setting it up.

### 1. Prerequisites on macOS

1. Install **UTM** from [https://mac.getutm.app](https://mac.getutm.app).
2. Download the Ubuntu 25.04 ARM64 ISO from the [https://cdimage.ubuntu.com/releases/25.04/release/](Ubuntu website).

---

### 2. Create a new VM in UTM

1. Open UTM → **+ New VM** → Virtualize → Linux
2. Allocate **CPU & Memory**
3. Check the `Use Apple Virtualization` box
4. Select **boot ISO image** and choose the downloaded Ubuntu ISO file
5. Add **storage**
6. Setup shared directory (TODO)
7. Rename the VM
8. Boot the VM
9. Select the `Try or Install Ubuntu` line.
10. Follow the installer guide and install Ubuntu on the VM.

> Personnal note : VM with 8192MiB memory, default CPU cores, 64GB storage does the job.

---

### 3. Setup Nix inside the VM

1. Simply run `just install` to install Nix, as well as the environnement specified by the Flake.
2. After the script, you should found yourself inside the working development environment.

---