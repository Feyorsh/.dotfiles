{ username, ... }:

{
  imports = [
    ../git
    ../editor/remote.nix
    ../terminal/common.nix
    ../nix.nix
    ../ssh.nix
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";

    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
}
