{ lib, pkgs, ... }:

{
  imports = [ ../nixos/swiss-army.nix ];

  environment.systemPackages = with pkgs; [
    unixtools.wall
    unixtools.watch
    iproute2mac
    darwin.ps
    cctools
  ];

  programs.vim.package = lib.mkOverride 500 pkgs.vim-darwin;
}
