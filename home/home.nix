{ config, pkgs, ... }:

{
    home.stateVersion = "23.11";

    home.file = {
        ".bashrc".source = ./bash/bashrc;
        ".bash_profile".source = ./bash/bash_profile;
    };

    programs.ssh.startAgent = true;
    programs.neovim.enable = true;
    programs.fzf.enable = true;
    programs.git = {
        enable = true;
        userName = "goncalogiga";
        userEmail = "goncalogiga@proton.me";
        signing.key = "/home/goncalogiga/.ssh/id_ed25519";
    };

    home.packages = with pkgs; [
        ripgrep
        fd
        bat
        eza
        kitty
        tree
        python3
        python3Packages.virtualenv
        direnv
    ];

    home.file.".ssh/id_ed25519.pub".source = ./ssh/id_ed25519.pub;

    xdg.configFile."nvim".source = ../nvim;
}