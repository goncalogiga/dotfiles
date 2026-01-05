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
            # Core
            git
            curl
            wget
            unzip
            ripgrep
            fd
            tree

            # Editor & terminal
            neovim
            kitty
            nodejs # Required by neovim

            # Dev tools
            python3
            python3Packages.pip
            nodejs
            docker
            docker-compose

            # Build tools
            gcc
            gnumake
            pkg-config
          ];

          shellHook = ''
            export EDITOR=nvim
            echo "🚀 Nix dev environment loaded for ${system}"
          '';
        };
      });
    };
}