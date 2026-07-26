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
    man-db.extraConfig = ''
      MANDATORY_MANPATH /run/current-system/sw/share/man
    '';
  };
  programs.info.enable = true;
}
