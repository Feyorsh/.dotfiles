{
  imports = [ ../nixos/nix.nix ];

  nix = {
    optimise.automatic = true;

    settings = {
      auto-optimise-store = false;

      trusted-users = [ "@admin" ];
    };
    nixPath = [
      "darwin=flake:darwin"
    ];
  };
}
