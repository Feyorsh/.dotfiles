{ pkgs, ... }:
{
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty-bin;
    settings = {
      macos-titlebar-proxy-icon = "hidden";
      macos-icon = "xray";
    };
  };
}
