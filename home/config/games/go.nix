{ pkgs, ... }:
{
  programs.emacs.extraPackages = epkgs: (with epkgs; [ gnugo pkgs.gnugo ]);
}
