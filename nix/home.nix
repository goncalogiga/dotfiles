{ config, lib, pkgs, ... }:

let
  dotfiles = "${config.home.homeDirectory}/dotfiles";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";

  # nvim expects python (with pynvim), black, isort and pyright under $DOTFILES_PATH/.venv/bin
  python = pkgs.python3.withPackages (ps: with ps; [ pynvim black isort ]);
  nvimVenv = pkgs.runCommand "nvim-venv" { } ''
    mkdir -p $out/bin
    ln -s ${python}/bin/{python,black,isort} ${pkgs.pyright}/bin/pyright-langserver $out/bin/
  '';
in
{
  # Same layout as scripts/macos-setup.sh, symlinked so edits in ~/dotfiles are live
  xdg.configFile."nvim".source = link "nvim";
  xdg.configFile."kitty/current-theme.conf".source = link "kitty/current-theme.conf";
  xdg.configFile."kitty/kitty.conf".text = ''
    include ${dotfiles}/kitty/kitty.conf
    # kitty.conf points at Homebrew's bash, use the login shell instead
    shell .
  '';
  home.file.".bashrc".source = link "bash/.bashrc";
  home.file.".bash_profile".text = "[ -f ~/.bashrc ] && . ~/.bashrc\n";
  home.file."dotfiles/.venv" = {
    source = nvimVenv;
    recursive = true;
  };

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

  home.stateVersion = "26.05";
}
