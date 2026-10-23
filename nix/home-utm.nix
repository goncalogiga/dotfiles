# GNOME settings for the UTM VM, on top of home.nix
{ lib, ... }:

{
  dconf.settings = {
    "org/gnome/shell".favorite-apps = [
      "kitty.desktop"
      "firefox.desktop"
      "org.gnome.Nautilus.desktop"
    ];
    "org/gnome/desktop/input-sources".sources = [
      (lib.hm.gvariant.mkTuple [ "xkb" "fr" ])
    ];
    # The display is software-rendered under Apple Virtualization
    "org/gnome/desktop/interface".enable-animations = false;
  };
}
