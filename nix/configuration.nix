{ pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix") # virtio drivers, also used by Apple Virtualization
    ./disko.nix
  ];

  nixpkgs.hostPlatform = "aarch64-linux";

  # UTM boots the EFI fallback path, no need to write EFI variables
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  networking.hostName = "utm";
  networking.networkmanager.enable = true;
  zramSwap.enable = true;

  # French AZERTY, for GDM and the text console
  services.xserver.xkb.layout = "fr";
  console.useXkbConfig = true;

  # Desktop
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.gnome.gnome-initial-setup.enable = false;
  programs.firefox.enable = true;
  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

  # UTM integration: clipboard sharing, and the optional shared directory
  services.spice-vdagentd.enable = true;
  fileSystems."/mnt/share" = {
    device = "share";
    fsType = "virtiofs";
    options = [ "noauto" "x-systemd.automount" "nofail" ];
  };

  services.openssh.enable = true;
  virtualisation.docker.enable = true;

  # Run prebuilt dynamically linked binaries (uv pythons, npm/plugin downloads...)
  programs.nix-ld.enable = true;

  users.users.goncalo = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    initialPassword = "nixos";
  };

  environment.systemPackages = import ./packages.nix pkgs ++ [ pkgs.kitty ];
  environment.variables.EDITOR = "nvim";
  environment.shellAliases.rebuild = "sudo nixos-rebuild switch --flake ~/dotfiles/nix#utm";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 14d";
  };

  system.stateVersion = "26.05";
}
