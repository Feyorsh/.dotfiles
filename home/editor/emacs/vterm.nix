{ pkgs, lib, ... }:
let
  inherit (pkgs.emacsPackages) vterm;
in
{
  programs.bash = {
    bashrcExtra = lib.mkAfter ''
      if [[ "$INSIDE_EMACS" == *"vterm"* ]]; then
        shopt -s globstar nullglob
        source ${vterm}/**/emacs-vterm-bash.sh
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

  programs.zsh = {
    initExtra = lib.mkAfter ''
      if [[ "$INSIDE_EMACS" == *"vterm"* ]]; then
        shopt -s globstar nullglob
        source ${vterm}/**/emacs-vterm-zsh.sh
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

  programs.fish = {
    interactiveShellInit = lib.mkAfter ''
      # for stuff that needs to work in other terminal emulators too, not just vterm
      if begin; [ -n "$INSIDE_EMACS" ]; end
         fish_default_key_bindings
      end

      if string match -qr "vterm" $INSIDE_EMACS
         source ${vterm}/**/emacs-vterm.fish

         function emacs
             vterm_find_file "$argv"
         end
         function man
             vterm_cmd man (string join " " -- "-l" (command man -w "$argv" 2>/dev/null))
         end
         alias ff='vterm_find_file'
      end
    '';
  };
}
