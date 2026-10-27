# CLI tools shared by the NixOS VM and the dev shell
pkgs: with pkgs; [
  # Core utilities
  curl
  wget
  unzip
  git
  just
  tree
  ripgrep
  fd
  fzf
  btop

  # Editor
  neovim
  nodejs # needed by neovim plugins
  lazygit
  tree-sitter

  # Dev tools
  python3
  uv
  poetry
  pyright

  # Rust
  cargo
  rustc
  rust-analyzer # LSP for neovim
  rustfmt
  clippy

  # Build tools
  gcc
  gnumake
  pkg-config
]
