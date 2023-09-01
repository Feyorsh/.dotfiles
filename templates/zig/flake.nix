{
  description = "All Your Codebase Are Belong To Us";
  # from https://github.com/mitchellh/zig-overlay/blob/main/templates/init/flake.nix

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    zig.url = "github:mitchellh/zig-overlay";
  };

  outputs = {self, nixpkgs, flake-utils, ...} @ inputs: let
    overlays = [
      (final: prev: {
        zigpkgs = inputs.zig.packages.${prev.system};
      })
    ];

    # Our supported systems are the same supported systems as the Zig binaries
    systems = builtins.attrNames inputs.zig.packages;
  in
    flake-utils.lib.eachSystem systems (
      system: let
        pkgs = import nixpkgs {inherit overlays system;};
      in rec {
        devShells = with pkgs; rec {
          nightly = mkShell {
            nativeBuildInputs = [
              zigpkgs.master
            ];
            buildInputs = [
              zls
            ];
          };
          stable = mkShell {
            nativeBuildInputs = [
              zigpkgs.default
            ];
            buildInputs = [
              zls
            ];
          };
          default = nightly;
        };
      }
    );
}
