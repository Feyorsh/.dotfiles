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

        vterm_notify_me_done() {
          vterm_cmd notify-me-done
        }
        PROMPT_COMMAND="''${PROMPT_COMMAND:+$PROMPT_COMMAND; }"'vterm_notify_me_done'

        vterm_find_file() {
          for arg in "''${@:-.}"; do
            vterm_cmd find-file "$(realpath "$arg")"
          done
        }
        alias ff='vterm_find_file'

        vterm_less() {
          printf "\e]51;Eless \""
          cat | base64 -w0
          printf "\"\e\\"
        }
        alias eless=vterm_less

        man() {
          vterm_cmd man "-l $(command man -w "$@" 2>/dev/null)"
        }
        emacs() {
          vterm_find_file
        }
      fi
    '';
  };

  programs.zsh = {
    initExtra = lib.mkAfter ''
      if [[ "$INSIDE_EMACS" == *"vterm"* ]]; then
        shopt -s globstar nullglob
        source ${vterm}/**/emacs-vterm-zsh.sh
        shopt -u globstar nullglob

        vterm_find_file() {
          for arg in "''${@:-.}"; do
            vterm_cmd find-file "$(realpath "$arg")"
          done
        }
        alias ff='vterm_find_file'

        vterm_less() {
          printf "\e]51;Eless \""
          cat | base64 -w0
          printf "\"\e\\"
        }
        alias eless=vterm_less

        man() {
          vterm_cmd man "-l $(command man -w "$@" 2>/dev/null)"
        }
        emacs() {
          vterm_find_file
        }
      fi
    '';
  };

  programs.fish = {
    interactiveShellInit = lib.mkAfter ''
      # for stuff that needs to work in other emacs terminal emulators too, not just vterm
      if begin; [ -n "$INSIDE_EMACS" ]; end
         fish_default_key_bindings
      end

      if string match -qr "vterm" $INSIDE_EMACS
         source ${vterm}/**/emacs-vterm.fish

         function vterm_notify_me_done --on-event fish_prompt
             vterm_cmd notify-me-done
         end

         function vterm_find_file
             set -q argv[1]; or set argv[1] "."
             for arg in $argv
                 vterm_cmd find-file (realpath "$arg")
             end
         end
         alias ff='vterm_find_file'

         function vterm_less
             printf "\e]51;Eless \""
             cat | base64 -w0
             printf "\"\e\\"
         end
         alias eless='vterm_less'

         function emacs
             vterm_find_file "$argv"
         end
         function man
             vterm_cmd man (string join " " -- "-l" (command man -w "$argv" 2>/dev/null))
         end
      end
    '';
  };
}
