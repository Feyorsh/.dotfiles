{ pkgs, ... }:
{
  programs.emacs.extraPackages = epkgs: (with epkgs; [
    hledger-mode pkgs.hledger
  ]);
}
