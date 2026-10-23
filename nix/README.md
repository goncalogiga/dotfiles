# nix

A NixOS VM for [UTM](https://mac.getutm.app) on Apple silicon, configured by
this flake: GNOME, kitty, neovim and the CLI tools from `packages.nix`, with
the dotfiles from this repo symlinked in place.

| File | Purpose |
|------|---------|
| `flake.nix` | Inputs, the `utm` system, the `install` app, the home-manager configs and the dev shell |
| `configuration.nix` | System: boot, desktop, UTM integration, user, packages |
| `home.nix` | home-manager: links nvim, kitty and bash configs from `~/dotfiles` |
| `home-utm.nix` | home-manager: GNOME settings for the VM |
| `home-linux.nix` | home-manager on non-NixOS Linux: packages, font, user |
| `disko.nix` | Disk layout (EFI + ext4 on `/dev/vda`) |
| `packages.nix` | CLI tools shared by the VM and `nix develop` |
| `install.sh` | Installer run from the live ISO |

## Install

1. Download the **minimal ISO, aarch64** from <https://nixos.org/download/#nixos-iso>.
2. In UTM: **+ → Virtualize → Linux**, tick **Use Apple Virtualization**,
   select the ISO, give it 4+ CPU cores, 8 GiB of memory and 64 GiB of disk. Optionally add
   a shared directory, and enable clipboard sharing in the VM settings.
   Before the first boot, add a **Serial** device. The minimal ISO doesn't
   drive UTM's display, which shows *"Display output is not active"*, so use
   the serial console instead.
3. Boot the VM. In the serial window, once at the `nixos@nixos` prompt (press
   Enter if it stays blank), run:

```bash
sudo nix --extra-experimental-features 'nix-command flakes' \
   run 'github:goncalogiga/dotfiles?dir=nix#install'
```

   It partitions the disk (type `yes` to confirm), clones this repo to
   `~/dotfiles` and installs the system.
4. Remove the ISO, otherwise the VM boots the installer again:
   - Shut down the VM (`sudo poweroff`).
   - In UTM, select the VM → **Edit** → **Drives**, then select the **USB
     Drive** holding the ISO (about 1.7 GB) and **Clear** or delete it. Keep
     the 64 GB VirtIO drive: NixOS is installed there.
   - Save, and boot again.
5. Log in as `goncalo` with password `nixos`, then run `passwd`.

## Usage

The system is built from `~/dotfiles/nix`, so edit, commit and run:

```bash
rebuild   # sudo nixos-rebuild switch --flake ~/dotfiles/nix#utm
```

To bump nixpkgs, run `nix flake update` in this directory, then `rebuild`.
Configs in `~/dotfiles` (nvim, kitty, bash) are symlinked, so changes to them
apply without a rebuild.

- **Shared directory**: mounted on first access at `/mnt/share`.
- **Clipboard**: goes through `spice-vdagent`. This is best effort under
  GNOME Wayland. As a fallback, SSH in from macOS: `ssh goncalo@<vm-ip>`.
- **Prebuilt binaries** (uv-managed Pythons, plugin downloads) work through
  `nix-ld`.

## Other Linux distributions

`scripts/setup.sh` applies `home.nix` and `home-linux.nix` with standalone
home-manager, see the [main README](../README.md#linux). The dev shell is still
available on any Linux with nix:

```bash
nix develop ~/dotfiles/nix
```
