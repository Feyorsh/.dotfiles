{ inputs, pkgs, lib, ... }:
let
  rinse = "nh home switch ~/.dotfiles";
  lave = "nh darwin switch ~/.dotfiles";
  powerwash = "deploy ~/.dotfiles --skip-checks";
  nix-unfetter = "nix-store --option sandbox false --realise";
  nixc = pkgs.writeShellScriptBin "nixc" (nixc' true);
  nixcf = pkgs.writeShellScriptBin "nixcf" (nixc' false);
  nixc' = tofrom: ''
    if ! [ "$#" -gt 0 ] && [ "$#" -lt 4 ]; then
      echo "usage: $0 [host] <path:result> <jump-host>" >&2
      exit 1
    fi

    if [ -n "$3" ]; then
      local -x NIX_SSHOPTS="-J $3"
    fi
    nix copy ${if tofrom then "--to" else "--from"} "ssh://$1" $(readlink "''${2:-result}" | tee /dev/tty)
  '';
in
{
  home.packages = with pkgs; [
    nix-output-monitor
    nh
    nixpkgs-review
    nixfmt-rs
    nix-prefetch
    inputs.deploy-rs.packages.${pkgs.stdenv.system}.deploy-rs

    nixc
    nixcf
  ];

  programs.nix-index = {
    enable = true;
    enableFishIntegration = true;
  };

  home.shellAliases = {
    inherit rinse lave powerwash nix-unfetter;
  };

  programs.fish.functions = {
    nix-hashit = "echo sha256-(nix hash convert --hash-algo sha256 --to base64 $argv)";
    ",," = "string match -r '/nix/store/.*/' $PATH[1]";
    ",,," = "open -na (,,)/Applications/*.app";
    # this nonsense is necessary due to home manager's user environment creating too large of a sandbox-exec profile on macOS.
    rinse-ng = ''
      set path (${lib.getExe pkgs.nh} home switch ~/.dotfiles &| tee /dev/tty &| rg "while waiting for the build environment for '(.*?)'" -o -r '$1')
      if test -n "$path"
          nix-store --realise $path --option sandbox false &>/dev/null
          ${lib.getExe pkgs.nh} home switch ~/.dotfiles
      end
    '';
  };
}
