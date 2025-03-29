{ pkgs, ... }:
{
  home.packages = with pkgs; [
    (manix.overrideAttrs (prev: {
      patches = (prev.patches or []) ++ [ (fetchpatch {
        url = "https://patch-diff.githubusercontent.com/raw/nix-community/manix/pull/27.patch";
        hash = "sha256-d+gOQweIUBPJkXENTkIzYNH0iqDMW4CXuweI8wZDydU=";
      }) ];
    }))
    nix-search-cli

    man-pages
    gcc.info
  ];

  manual.manpages.enable = false;
  # manual.json.enable = true; # manix
  programs.man.generateCaches = true;
  programs.info.enable = true;

  programs.nix-index = {
    enable = true;
    enableFishIntegration = true;
  };

  # (runCommand "nix-manuals" { nativeBuildInputs = [ docbook2x ]; } ''
  #   mkdir -p $out/info
  #   docbook2texi
  #   ln -s ${pkgs.darwin.xcode_16_1}/* $out/Applications/Xcode.app/
  #  '')
}
