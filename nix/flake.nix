{
  description = "Common development environment for Ubuntu VM";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = f:
        nixpkgs.lib.genAttrs supportedSystems (system:
          f {
            inherit system;
            pkgs = nixpkgs.legacyPackages.${system};
          });
    in
    {
      devShells = forAllSystems ({ pkgs, system }: {
        default = pkgs.mkShell {
          name = "vm-dev-shell";

          packages = with pkgs; [
            # Core utilities
            wget
            unzip
            ripgrep
            fd
            tree

            # Editor
            neovim
            nodejs   # needed by neovim plugins
            lazygit
            tree-sitter
            python3Packages.pynvim

            # Dev tools
            python3
            uv
            poetry
            pyright
            python3Packages.pip
            python3Packages.black
            python3Packages.isort

            # Rust
            cargo

            # Build tools
            gcc
            gnumake
            pkg-config

            # Terminal
            btop
          ];

          shellHook = ''
            # Idempotent environment setup
            if [ -z "''${EDITOR:-}" ]; then
              export EDITOR=nvim
            fi
          '';
        };
      });
    };
}
