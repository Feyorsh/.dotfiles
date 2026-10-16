{ inputs, pkgs, lib, host, ... }:
let
  rinse = "nh home switch ~/.dotfiles#homeConfigurations.${host}";
  lave = "nh darwin switch ~/.dotfiles#darwinConfigurations${host}";
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
  nixl = pkgs.writeShellApplication {
    name = "nixl";
    runtimeInputs = with pkgs; [ fd gnused ];
    text = ''
      if [ "$#" -gt 1 ]; then
        echo "usage: $0 [store-path | -+]" >&2
        return 1
      fi

      if [ "$#" -eq 0 ]; then
        if [[ -L result ]]; then
          arg=result
        else
          arg=-
        fi
      else
        arg="$1"
      fi

      if [ -L "$arg" ]; then
        realp=$(readlink -f -- "$arg") || return
        if [[ "$realp" == /nix/store/* ]]; then
          target="$realp"
        else
          echo "$0: '$arg' does not point to a store path" >&2
          return 1
        fi
      elif [[ $arg =~ ^-+$ ]]; then
        entry=$(fd -t f . /nix/var/log/nix/drvs -x stat -c '%Y %n' | sort -nr | sed -n "''${#arg}p")
        [[ -n $entry ]] || return 1
        target=$(sed -E 's@^[0-9]+ /nix/var/log/nix/drvs/([^/]+)/([^/]+)\.drv(\.bz2)?$@/nix/store/\1\2.drv@' <<< "$entry")
      else
        echo "$0: invalid argument '$arg'" >&2
        return 1
      fi

      nix log "$target"
    '';
  };
in
{
  home.packages = with pkgs; [
    nix-output-monitor
    nh
    nixpkgs-review
    nixpkgs-lint
    nixfmt-rs
    nix-prefetch
    inputs.deploy-rs.packages.${pkgs.stdenv.system}.deploy-rs

    nixc
    nixcf
    nixl
  ];

  programs.nix-index = {
    enable = true;
    enableFishIntegration = true;
  };

  home.shellAliases = {
    inherit rinse lave nix-unfetter;
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
