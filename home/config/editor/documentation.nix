{ pkgs, ... }:
{
  home.packages = with pkgs; [
    man-pages
    gcc.info
    binutils.info
  ];

  manual.manpages.enable = false;
  programs.man = {
    generateCaches = true;
    # extraConfig = ''
    #   MANDATORY_MANPATH /var/run/current-system/sw/share/man
    # '';
  };
  programs.info.enable = true;

  # (runCommand "nix-manuals" { nativeBuildInputs = [ docbook2x ]; } ''
  #   mkdir -p $out/info
  #   docbook2texi
  #   ln -s ${pkgs.darwin.xcode_16_1}/* $out/Applications/Xcode.app/
  #  '')
}
