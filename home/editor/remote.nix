{ pkgs, lib, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) isLinux system;
  tramp-rpc = pkgs.emacsPackages.tramp-rpc.override { archs = [ pkgs ]; };
in
{
  imports = [
    ./common.nix
    ./emacs/vterm.nix
  ];

  home.packages = with pkgs; lib.mkIf isLinux [
    inotify-tools # for tramp
  ];

  xdg.cacheFile."emacs/tramp-rpc/tramp-rpc-server-${tramp-rpc.version}" = {
    enable = true;
    executable = true;
    source = lib.findFirst (lib.hasSuffix "binaries/${system}/tramp-rpc-server") null (lib.filesystem.listFilesRecursive tramp-rpc);
  };
}
