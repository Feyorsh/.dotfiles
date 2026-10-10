{ pkgs, lib, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) isLinux;
in
{
  imports = [
    ./common.nix
    ./emacs/vterm.nix
  ];

  home.packages = with pkgs; lib.mkIf isLinux [
    inotify-tools # for tramp
  ];

  xdg.cacheFile."emacs/tramp-rpc/tramp-rpc-server-${pkgs.emacs-tramp-rpc-server.version}" = {
    enable = true;
    executable = true;
    source = "${pkgs.emacs-tramp-rpc-server}/bin/tramp-rpc-server";
  };
}
