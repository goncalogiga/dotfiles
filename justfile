set shell := ["bash", "-cu"]

default:
    just --list

install:
    @echo "🛠️ Installing full VM environment"
    bash scripts/install.sh

nix-shell:
    cd nix && nix develop

update:
    nix flake update

doctor:
    nix --version
    which nvim
    which kitty