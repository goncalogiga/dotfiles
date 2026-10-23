# dotfiles

This repository contains my development setup accross platforms.

## Linux

On distributions like Ubuntu or Debian, the same home-manager config as the
NixOS VM runs standalone on top of the system, see
[nix/home-linux.nix](nix/home-linux.nix). Clone the repo to `~/dotfiles`, since
the config expects it there:

```bash
git clone https://github.com/goncalogiga/dotfiles ~/dotfiles
cd ~/dotfiles
bash scripts/setup.sh
```

The script installs nix (with flakes), kitty and docker. Then home-manager
installs the tools from [nix/packages.nix](nix/packages.nix) and the
JetBrains Mono Nerd Font, links the nvim, kitty and bash configs, and sets up
the neovim python environment. Existing files are renamed to `*.bak`.

Log out and back in (or reboot) afterwards. Configs are symlinked, so edits in
`~/dotfiles` apply right away. After changing `nix/`, run:

```bash
rebuild   # home-manager switch --flake ~/dotfiles/nix#goncalo-$(uname -m)
```

## MacOS

MacOS setup does not use nix since it's not so important to have strict
reproducability. The script installs the following packages: `neovim`, `bash`,
`kitty`, `tree-sitter`, `lazygit`, `fzf`, `fd`, `ripgrep`, `uv`, `node`,
`btop`, `coreutils`, `sbx`, `vorssaint`, and `Karabiner-Elements`. 

It also sets up the neovim python environment, links dotfiles, configures
shell profiles, sets the Dock to auto-hide and only show running apps, and
hides desktop icons (see [scripts/macos-setup.sh](scripts/macos-setup.sh) to
revert).

We can setup the base neovim development environment with : 

```bash
bash scripts/macos-setup.sh
```

### Optional Checklist

- [ ] Firefox (+ Ublock add-on)
- [ ] KeePassium
- [ ] Better Display
- [ ] UTM
- [ ] Docker
- [ ] Spotify

Other stuff for personnal use:

- [ ] Tailscale (Personnal)
- [ ] ProtonVPN (Personnal)
- [ ] Whatsapp, Signal, Slack (Personnal)
- [ ] Numbers (Personnal)


## NixOS VM on macOS

For a linux VM on MacOS, I use a NixOS VM with UTM, installed with a single
command from the live ISO. See [nix/README.md](nix/README.md).
