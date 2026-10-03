{ username, config, pkgs, ... }:

{
  imports = [
    ../git
    ../editor/remote.nix
    ../terminal/common.nix
    ../terminal/shell/default.nix
    ../nix.nix
    ../ssh.nix
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";

    stateVersion = "26.05";
  };

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

  programs.home-manager.enable = true;
}
