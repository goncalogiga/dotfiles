# Standalone home-manager on non-NixOS Linux (Ubuntu...), on top of home.nix
{ pkgs, ... }:

{
  home.username = "goncalo";
  home.homeDirectory = "/home/goncalo";

  # PATH, XDG_DATA_DIRS and locales for nix packages on a foreign distro
  targets.genericLinux.enable = true;
  programs.home-manager.enable = true;

  # What configuration.nix provides system-wide on NixOS. kitty comes from apt,
  # nix GUI apps need extra OpenGL setup outside NixOS
  home.packages = import ./packages.nix pkgs ++ [ pkgs.nerd-fonts.jetbrains-mono ];
  fonts.fontconfig.enable = true;
  home.sessionVariables.EDITOR = "nvim";

  dconf.settings."org/gnome/shell/extensions/dash-to-dock".autohide = true;
}
