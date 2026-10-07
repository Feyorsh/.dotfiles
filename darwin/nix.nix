{ lib, pkgs, ... }:

{
  imports = [ ../nixos/nix.nix ];

  nix = {
    optimise.automatic = true;

    settings = {
      auto-optimise-store = lib.mkForce false;

      trusted-users = lib.mkForce [ "root" "@admin" ];
    };
    nixPath = [
      "darwin=flake:darwin"
    ];
  };
}
