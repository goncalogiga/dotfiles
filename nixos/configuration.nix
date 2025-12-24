{ config, pkgs, ... }:

{
    system.stateVersion = "23.11";

    # Bootloader (UTM-friendly)
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "nixos-vm";
    networking.networkmanager.enable = true;

    time.timeZone = "Europe/Paris";

    i18n.defaultLocale = "en_US.UTF-8";

    users.users.youruser = {
        isNormalUser = true;
        description = "goncalogiga";
        extraGroups = [ "wheel" "docker" "networkmanager" ];
        shell = pkgs.bash;
    };

    security.sudo.wheelNeedsPassword = false;

    # SSH
    services.openssh = {
        enable = true;
        settings.PasswordAuthentication = false;
    };

    # Desktop UI (GNOME)
    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;

    # X11 + Wayland
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;

    # GPU acceleration
    hardware.opengl.enable = true;

    # Wayland
    services.xserver.windowManager.enable = false; # GNOME uses Wayland by default

    # Sound
    sound.enable = true;
    hardware.pulseaudio.enable = false;
    services.pipewire = {
        enable = true;
        pulse.enable = true;
    };

    # Docker
    virtualisation.docker.enable = true;

    # Core system packages
    environment.systemPackages = with pkgs; [
        git
        neovim
        fzf
        wget
        curl
        python3
    ];

    # Home Manager
    home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.youruser = import ../home/home.nix;
    };
}