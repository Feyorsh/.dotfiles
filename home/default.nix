{ username, pkgs, ... }:

{
  home = {
    inherit username;
    homeDirectory = "/${if pkgs.stdenv.hostPlatform.isDarwin then "Users" else "home"}/${username}";
  };
  programs.home-manager.enable = true;

  home.preferXdgDirectories = true;
  xdg.enable = true;
}
