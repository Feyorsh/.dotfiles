{ pkgs, ... }:

{
  imports = [
    ./dgamelaunch/module.nix
  ];

  nixpkgs.overlays = [
    (_: prev: let
      nethack-el = pkgs.emacsPackages.nethack;
    in {
      nethack = prev.nethack.overrideAttrs (p: {
        patches = (p.patches or []) ++ [ "${nethack-el.src}/enh-${builtins.replaceStrings ["."] [""] p.version}.patch" ];
      });
    })
  ];

  services.dgamelaunch = {
    enable = true;
    package = pkgs.callPackage ./dgamelaunch/default.nix { };
    enableSSH = true;
    telnetPort = 23;
  };
}
