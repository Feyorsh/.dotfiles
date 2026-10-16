{ pkgs, ... }:

{
  imports = [
    ../../home
    ../../home/editor/remote.nix
    ../../home/terminal/common.nix
    ../../home/terminal/shell/default.nix
  ];

  home.packages = with pkgs; [
    swaybg # wallpaper
  ];

  wayland.windowManager.niri = {
    enable = true;
    enableDefaultConfig = true;
    # TODO port key binds from macOS WM
    settings = {};
  };
  programs.fuzzel.enable = true;
  programs.waybar.enable = true;
  services.mako.enable = true;
  services.swayidle.enable = true;
  services.polkit-gnome.enable = true;

  home.stateVersion = "26.05";
}
