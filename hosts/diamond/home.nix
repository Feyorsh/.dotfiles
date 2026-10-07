{ pkgs, ... }:

{
  imports = [
    ../../home
    ../../home/editor/remote.nix
  ];

  home.packages = with pkgs; [
    uv
  ];

  home.stateVersion = "26.05";
}
