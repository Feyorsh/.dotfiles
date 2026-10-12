{
  imports = [ ../nixos/nix.nix ];

  nix = {
    optimise.automatic = true;

    settings = {
      auto-optimise-store = false;

      experimental-features = "nix-command flakes";

      trusted-users = [ "@admin" ];
    };
    nixPath = [
      "darwin=flake:darwin"
    ];
  };
}
