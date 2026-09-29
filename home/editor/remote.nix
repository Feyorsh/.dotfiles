{ pkgs, lib, ... }:

{
  imports = [
    ./common.nix
  ];

  home.packages = with pkgs; [
    inotify-tools # for tramp
  ];

  programs.bash = {
    bashrcExtra = lib.mkAfter ''
      if [[ "$INSIDE_EMACS" == *"vterm"* ]]; then
        shopt -s globstar nullglob
        source ${pkgs.emacsPackages.vterm}/**/emacs-vterm-bash.sh
        shopt -u globstar nullglob
        man() {
          vterm_cmd man "-l $(command man -w "$@" 2>/dev/null)"
        }
        emacs() {
          vterm_find_file "''${@:-.}"
        }
        alias ff='vterm_find_file'
      fi
    '';
  };
}
