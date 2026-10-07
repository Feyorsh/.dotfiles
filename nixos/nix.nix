{ lib, pkgs, host, ... }:
let
  remoteBuilders = import ../common/remote-builders.nix (lib.toLower host);
in
{
  nix = {
    inherit (remoteBuilders) buildMachines;

    enable = true;
    package = pkgs.nixVersions.latest;

    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };

    settings = {
      inherit (remoteBuilders)
        trusted-public-keys
        trusted-substituters
      ;

      auto-optimise-store = true;

      experimental-features = "nix-command flakes";

      keep-outputs = true;
      keep-derivations = true;

      trusted-users = [ "root" "@wheel" ];

      sandbox = true;

      fallback = true;
      warn-dirty = false;
    };

    extraOptions = ''
      builders-use-substitutes = true
    '';
    distributedBuilds = true;

    channel.enable = false;
    nixPath = [
      "nixpkgs=flake:nixpkgs"
      "home-manager=flake:home-manager"
    ];
  };
}
