# dotfiles

This repository contains my development setup accross platforms.

## MacOS

MacOS setup does not use nix since it's not so important to have strict
reproducability. The script installs the following packages: `neovim`, `bash`,
`kitty`, `tree-sitter`, `lazygit`, `fzf`, `fd`, `ripgrep`, `uv`, `node`,
`btop`, `coreutils`, `sbx`, `vorssaint`, and `Karabiner-Elements`. 
It also sets up the neovim python environment, links dotfiles, and configures
shell profiles.

We can setup the base neovim development environment with : 

```bash
just macos-setup
```

## NixOS VM on macOS

For a linux VM on MacOS, I use a NixOS VM with UTM, installed with a single
command from the live ISO. See [nix/README.md](nix/README.md).


### Optional Checklist

- [ ] Firefox (+ Ublock add-on)
- [ ] KeePassium
- [ ] Better Display
- [ ] Karabiner-Elements
- [ ] UTM
- [ ] Docker
- [ ] Spotify

Other stuff for personnal use:

- [ ] Tailscale (Personnal)
- [ ] ProtonVPN (Personnal)
- [ ] Whatsapp, Signal, Slack (Personnal)
- [ ] Numbers (Personnal)

