{ config, lib, pkgs, fpkgs, user, ... }: let
  aspell = with pkgs; (aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]));
in {
  home = {
    username = "ghuebner";
    homeDirectory = "/Users/ghuebner";

    packages = with pkgs; [
      spotify
      wezterm

      gimp
  
      # wrapper is broken(?) works when you install rosetta
      # https://github.com/NixOS/nixpkgs/commits/130e80523f73b8950568246d3b4c294825923448/pkgs/build-support/emacs/wrapper.nix
      # this doesn't play nicely with non-lisp packages like ledger and aspell
      ((emacsPackagesFor emacs29-macport).emacsWithPackages (epkgs: with epkgs; [
        vterm
        pdf-tools
        pkgs.mu
      ]))
      ledger
  
      mu
      isync
      msmtp

      aspell
      
      python312

      alt-tab-macos
      monitorcontrol
      fpkgs.time-out-macos
    ];
    file.".aspell.conf".text = "data-dir ${aspell}/lib/aspell";

    stateVersion = "23.05";

    # https://github.com/python-poetry/poetry/issues/5929
    #file.".config/fish/completions/poetry.fish".source = config.lib.file.mkOutOfStoreSymlink config.home.homeDirectory + /.dotfiles/config/fish/completions/poetry.fish;
  };
  programs.home-manager.enable = true;

  # TODO: add custom git command
  # git add --intent-to-add extra/flake.nix
  # git update-index --skip-worktree extra/flake.nix
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

      set -g SHELL ${config.home.profileDirectory}${config.programs.fish.package.shellPath}
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

  programs.alacritty = {
    enable = true;
    #settings = {
      #shell.program = "${config.home.profileDirectory}${config.programs.fish.package.shellPath}";
    #};
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.vim = {
    enable = true;
    extraConfig = ''
      if $INSIDE_EMACS == "vterm"
        silent! !vterm_printf "51;Eevil-emacs-state"
        autocmd VimLeave * :!vterm_printf "51;Eevil-insert-state"
      endif

      set number
      set relativenumber
      syntax enable
    '';
  };

  # TODO: make this a git command `git leaders`
  #git log --shortstat --pretty="%cE" | sed 's/\(.*\)@.*/\1/' | grep -v "^$" | awk 'BEGIN { line=""; } !/^ / { if (line=="" || !match(line, $0)) {line = $0 "," line }} /^ / { print line " # " $0; line=""}' | sort | sed -E 's/# //;s/ files? changed,//;s/([0-9]+) ([0-9]+ deletion)/\1 0 insertions\(+\), \2/;s/\(\+\)$/\(\+\), 0 deletions\(-\)/;s/insertions?\(\+\), //;s/ deletions?\(-\)//' | awk 'BEGIN {name=""; files=0; insertions=0; deletions=0;} {if ($1 != name && name != "") { print name ": " files " files changed, " insertions " insertions(+), " deletions " deletions(-), " insertions-deletions " net"; files=0; insertions=0; deletions=0; name=$1; } name=$1; files+=$2; insertions+=$3; deletions+=$4} END {print name ": " files " files changed, " insertions " insertions(+), " deletions " deletions(-), " insertions-deletions " net";}'

  # xdg.configFile."nixpkgs/config.nix".text = ''
  #   {
  #     allowUnfree = true;
  #   }
  # '';

#  programs.gpg = {
#    enable = true;
#    package = pkgs.gnupg.overrideAttrs (previous: rec {
#                pname = "gnupg";
#                version = "2.4.0";
#                src = pkgs.fetchurl {
#                    url = "mirror://gnupg/gnupg/${pname}-${version}.tar.bz2";
#                    hash = "sha256-HXkVjdAdmSQx3S4/rLif2slxJ/iXhOosthDGAPsMFIM=";
#                };
#              });
#    mutableKeys = true;
#    mutableTrust = true;
#  };
#  services.gpg-agent = {
#    enable = true;
#    defaultCacheTtl = 1200;
#    maxCacheTtl = 86400;
#    pinentryFlavor = null;
#    extraConfig = ''
#      pinentry-program '' +
#    pkgs.writeShellScript "custom-pinentry" ''
#      case $PINENTRY_USER_DATA in
#      emacs)
#          exec ${pkgs.pinentry.emacs}/bin/pinentry "$@"
#          ;;
#      gtk)
#          exec ${pkgs.pinentry.gtk2}/bin/pinentry "$@"
#          ;;
#      *)
#          exec ${pkgs.pinentry.tty}/bin/pinentry "$@"
#      esac
#    '' + ''
#
#      allow-emacs-pinentry
#      allow-loopback-pinentry
#    '';
#  };
}
