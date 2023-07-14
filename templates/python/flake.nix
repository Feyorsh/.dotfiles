{
  description = "Beautiful is better than ugly";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, poetry2nix, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        inherit (poetry2nix.legacyPackages.${system})
          mkPoetryApplication mkPoetryEnv;
        pkgs = import nixpkgs { inherit system; };
      in rec {
        devShells.default = with pkgs; mkShellNoCC {
          packages = [
            poetry
            nodePackages.pyright
            #(mkPoetryEnv { projectDir = self; preferWheels = true; })
          ];
        };
      });
}
