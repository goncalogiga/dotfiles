{
  description = "NixOS VM for UTM, and a common dev shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, disko }:
    let
      forAllSystems = f:
        nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ]
          (system: f nixpkgs.legacyPackages.${system});
    in
    {
      # sudo nixos-rebuild switch --flake ~/dotfiles/nix#utm
      nixosConfigurations.utm = nixpkgs.lib.nixosSystem {
        modules = [
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          ./configuration.nix
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "bak";
              users.goncalo = ./home.nix;
            };
          }
        ];
      };

      # Run from the NixOS live ISO, see README.md
      apps.aarch64-linux.install =
        let pkgs = nixpkgs.legacyPackages.aarch64-linux;
        in {
          type = "app";
          meta.description = "Install the utm configuration from the NixOS live ISO";
          program = nixpkgs.lib.getExe (pkgs.writeShellApplication {
            name = "install-utm";
            runtimeInputs = [ pkgs.git ];
            runtimeEnv.DISKO = self.nixosConfigurations.utm.config.system.build.diskoScript;
            text = builtins.readFile ./install.sh;
          });
        };

      # nix develop ~/dotfiles/nix (non-NixOS Linux, e.g. Ubuntu)
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          name = "vm-dev-shell";
          packages = import ./packages.nix pkgs ++ (with pkgs.python3Packages; [
            pip
            pynvim
            black
            isort
          ]);
          shellHook = ''
            export EDITOR="''${EDITOR:-nvim}"
          '';
        };
      });
    };
}
