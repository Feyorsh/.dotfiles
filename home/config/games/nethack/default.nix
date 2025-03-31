{ pkgs, ... }:
{
  home.file.".nethackrc".source = ./nethackrc;

  home.packages = with pkgs; [ nethack ];

  programs.emacs.extraPackages = epkgs: (with epkgs; [ (pkgs.callPackage ./package.nix { inherit trivialBuild; }) ]);
}
