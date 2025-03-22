{ pkgs, ... }:
{
  home.packages = with pkgs; [ gnugo ];

  programs.emacs.extraPackages = epkgs: (with epkgs; [ gnugo ]);
}
