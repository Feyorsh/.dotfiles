{ pkgs, ... }:
{
  programs.emacs.extraPackages = epkgs: (with epkgs; [
    ledger-mode pkgs.ledger
  ]);
}
