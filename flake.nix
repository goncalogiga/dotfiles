{
  description = "NixOS systems and tools";

  inputs = {
    # Stable NixOS
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    # Unstable channel for selected packages
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # Bleeding edge (use with care)
    nixpkgs-master.url = "github:nixos/nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
    let
      inherit (self) outputs;
      inherit (nixpkgs.lib) nixosSystem;
      specialArgs = { inherit inputs outputs; };
    in
    {
      overlays = import ./nix/overlays { inherit inputs; };

      nixosConfigurations = {
        vm = nixosSystem {
          specialArgs = specialArgs;

          modules = [
            home-manager.nixosModules.home-manager

            {
              home-manager.users.goncalo =
                import ./nix/home/goncalo;

              home-manager.extraSpecialArgs = specialArgs;
            }

            ./nix/system/vm
          ];
        };
      };
    };
}
