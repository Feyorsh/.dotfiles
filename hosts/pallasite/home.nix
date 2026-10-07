{ config, pkgs, ... }:

{
  imports = [
    ../../home
    ../../home/git
    ../../home/editor/remote.nix
    ../../home/terminal/common.nix
    ../../home/terminal/shell/default.nix
    ../../home/nix.nix
    ../../home/ssh.nix
  ];

  home.stateVersion = "26.05";

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
    theme = {
      name = "Adwaita";
      package = pkgs.gnome-themes-extra;
    };
  };
  qt = {
    enable = true;
    style.name = "adwaita-dark";
  };

  home.sessionVariables.LM_LICENSE_FILE = "${config.home.homeDirectory}/Personal/sighacks/licenses/qpro.dat";
}
