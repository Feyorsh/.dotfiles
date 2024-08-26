{ config, pkgs, ... }:
{
  programs.fish = {
    enable = true;
    shellInit = ''
      function vterm_printf;
          if begin; [  -n "$TMUX" ]  ; and  string match -q -r "screen|tmux" "$TERM"; end 
              # tell tmux to pass the escape sequences through
              printf "\ePtmux;\e\e]%s\007\e\\" "$argv"
          else if string match -q -- "screen*" "$TERM"
              # GNU screen (screen, screen-256color, screen-256color-bce)
              printf "\eP\e]%s\007\e\\" "$argv"
          else
              printf "\e]%s\e\\" "$argv"
          end
      end

      function alert
          command $argv; afplay (random choice ~/Profile/Sounds/*) &
      end

      # set -g SHELL ${config.home.profileDirectory}${config.programs.fish.package.shellPath}
    '';
    interactiveShellInit = ''
      function vterm_prompt_end;
          vterm_printf '51;A'(whoami)'@'(hostname)':'(pwd)
      end
      functions --copy fish_prompt vterm_old_fish_prompt
      function fish_prompt --description 'Write out the prompt; do not replace this. Instead, put this at end of your file.'
          # Remove the trailing newline from the original prompt. This is done
          # using the string builtin from fish, but to make sure any escape codes
          # are correctly interpreted, use %b for printf.
          printf "%b" (string join "\n" (vterm_old_fish_prompt))
          vterm_prompt_end
      end

      set -g async_prompt_functions _pure_prompt_git

      direnv hook fish | source

      set fish_cursor_default     block      blink
      set fish_cursor_insert      line       blink
      set fish_cursor_replace_one underscore blink
      set fish_cursor_visual      block

      if begin; [ -n "$INSIDE_EMACS" ] ; end
         fish_default_key_bindings
      else
        fish_vi_key_bindings
      end
    '';
    functions = {
      nix_shell_packages = ''
        if [ $SHLVL -ge 3 ]
            for p in $PATH
                if not string match -qgr "/nix/store/.*?-(?<pname>.*)-\d*\.\d*\.\d*/" $p; or [ $pname = "kitty" ]
                    break
                end
                echo $pname
            end
        end
      '';
    };
    plugins = [
      { name = "pure"; src = pkgs.fishPlugins.pure.src; }
      { name = "fishplugin-async-prompt"; src = pkgs.fishPlugins.async-prompt.src; }
    ];
  };

  # https://github.com/python-poetry/poetry/issues/5929
  # file.".config/fish/completions/poetry.fish".source = config.lib.file.mkOutOfStoreSymlink config.home.homeDirectory + /.dotfiles/config/fish/completions/poetry.fish;
}
