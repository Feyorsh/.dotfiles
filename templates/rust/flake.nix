{
  description = "Rewrite it, but in Rust";
  # from https://github.com/oxalica/rust-overlay

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };
      in with pkgs; {
        devShells = rec {
          stable = mkShell {
            buildInputs = [
              (rust-bin.stable.latest.default.override {
                extensions = [ "rust-analyzer-preview" ];
              })
            ];
          };
          nightly = mkShell {
            buildInputs = [
              (rust-bin.selectLatestNightlyWith (toolchain:
                toolchain.default.override {
                  extensions = [ "rust-analyzer-preview" ];
                  # targets = [ "thumbv7em-none-eabihf" ];
                }))
            ];
          };
          default = stable;
        };
      });
}
