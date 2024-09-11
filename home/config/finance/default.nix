{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    ledger
  ];

  programs.emacs.extraPackages = epkgs: (with epkgs; [
    ledger-mode
  ]);
}
