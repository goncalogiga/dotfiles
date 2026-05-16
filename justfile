set shell := ["bash", "-cu"]

default:
    just --list

# Setup the dev environment
setup:
    bash scripts/setup.sh

# Setup the dev environment for MacOS (no nix here)
macos-setup:
    bash scripts/macos-setup.sh

# Activate the dev environment
dev:
    cd nix && nix develop

# Update the nix flake
update:
    nix flake update

# Encrypt secrets
encrypt:
    bash scripts/secrets.sh encrypt secrets/

# Decrypt secrets
decrypt:
    bash scripts/secrets.sh decrypt secrets/

# Setup git hooks
setup-hooks:
    git config core.hooksPath git/hooks/
