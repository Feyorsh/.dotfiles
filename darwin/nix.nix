{ lib, pkgs, ... }:

{
  imports = [ ../nixos/nix.nix ];

  nix = {
    optimise.automatic = true;

    settings = {
      auto-optimise-store = lib.mkOverride 500 false;

      trusted-users = lib.mkOverride 500 [ "root" "@admin" ];
    };
    nixPath = [
      "darwin=flake:darwin"
    ];
  };
}
