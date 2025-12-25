{ config, pkgs, lib, inputs, outputs, ... }:
{
    home.username = "goncalo";
    home.homeDirectory = "/home/goncalo";
    home.stateVersion = "23.11";

    home.file = {
        ".bashrc".source = inputs.self + /bash/bashrc;
        ".bash_profile".source = inputs.self + /bash/bash_profile;
    };

    programs.ssh = {
        enable = true;
    };

    home.file.".ssh/id_ed25519.pub".source =
        inputs.self + /ssh/id_ed25519.pub;

    programs.git = {
        enable = true;
        userName = "goncalogiga";
        userEmail = "goncalogiga@proton.me";

        signing = {
            key = "~/.ssh/id_ed25519";
            signByDefault = true;
        };

        extraConfig = {
            init.defaultBranch = "main";
            pull.rebase = false;
        };
    };

    programs.neovim = {
        enable = true;
        defaultEditor = true;
    };

    xdg.configFile."nvim".source =
        inputs.self + /nvim;

    programs.fzf.enable = true;
    programs.direnv.enable = true;
    programs.direnv.nix-direnv.enable = true;

    home.packages = with pkgs; [
        kitty
        ripgrep
        fd
        bat
        eza
        tree
        python3
        python3Packages.virtualenv
    ];
}