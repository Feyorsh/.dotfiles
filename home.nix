{ config, lib, pkgs, user, ... }: {
  home = {
    username = "ghuebner";
    homeDirectory = "/Users/ghuebner";

    packages = with pkgs; [
#      ((emacsPackagesFor emacs29-pgtk).emacsWithPackages (epkgs: [ epkgs.vterm epkgs.pdf-tools pkgs.mu ]))
#      aspell
#      aspellDicts.en

#      # fonts
#      (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
#      source-sans-pro
#      sarasa-gothic
#      jetbrains-mono
#      twitter-color-emoji
#      emacs-all-the-icons-fonts
#
#      python312 # 1 for 2 projects where this hasn't caused compat issues :P
#      nodePackages.pyright
#
#      # mail
#      mu
#      isync
#      msmtp
    ];

    stateVersion = "23.05";

    # I'm not symlinking this, because init.el should exist independently of HM and Nix
    #file.".config/emacs".source = config.lib.file.mkOutOfStoreSymlink ../config/emacs;

    # https://github.com/python-poetry/poetry/issues/5929
    #file.".config/fish/completions/poetry.fish".source = config.lib.file.mkOutOfStoreSymlink config.home.homeDirectory + /.dotfiles/config/fish/completions/poetry.fish;
  };
  programs.home-manager.enable = true;

  #programs.emacs = {
  # enable = true;
  # extraPackages = epkgs: [ epkgs.emacs-libvterm epkgs.pdf-tools ];
  #};

#  programs.fish = {
#    enable = true;
#    shellInit = ''
#      function vterm_printf;
#          if begin; [  -n "$TMUX" ]  ; and  string match -q -r "screen|tmux" "$TERM"; end 
#              # tell tmux to pass the escape sequences through
#              printf "\ePtmux;\e\e]%s\007\e\\" "$argv"
#          else if string match -q -- "screen*" "$TERM"
#              # GNU screen (screen, screen-256color, screen-256color-bce)
#              printf "\eP\e]%s\007\e\\" "$argv"
#          else
#              printf "\e]%s\e\\" "$argv"
#          end
#      end
#
#      set -g SHELL ${config.home.profileDirectory}${config.programs.fish.package.shellPath}
#    '';
#    interactiveShellInit = ''
#      function vterm_prompt_end;
#          vterm_printf '51;A'(whoami)'@'(hostname)':'(pwd)
#      end
#      functions --copy fish_prompt vterm_old_fish_prompt
#      function fish_prompt --description 'Write out the prompt; do not replace this. Instead, put this at end of your file.'
#          # Remove the trailing newline from the original prompt. This is done
#          # using the string builtin from fish, but to make sure any escape codes
#          # are correctly interpreted, use %b for printf.
#          printf "%b" (string join "\n" (vterm_old_fish_prompt))
#          vterm_prompt_end
#      end
#
#      set -g async_prompt_functions _pure_prompt_git
#
#      direnv hook fish | source
#
#      set fish_cursor_default     block      blink
#      set fish_cursor_insert      line       blink
#      set fish_cursor_replace_one underscore blink
#      set fish_cursor_visual      block
#
#      if begin; [ -n "$INSIDE_EMACS" ] ; end
#         fish_default_key_bindings
#      else
#        fish_vi_key_bindings
#      end
#    '';
#    functions = {
#      nix_shell_packages = ''
#        if [ $SHLVL -ge 3 ]
#            for p in $PATH
#                if not string match -qgr "/nix/store/.*?-(?<pname>.*)-\d*\.\d*\.\d*/" $p; or [ $pname = "kitty" ]
#                    break
#                end
#                echo $pname
#            end
#        end
#      '';
#    };
#    plugins = [
#      { name = "pure"; src = pkgs.fishPlugins.pure.src; }
#      { name = "fishplugin-async-prompt"; src = pkgs.fishPlugins.async-prompt.src; }
#    ];
#  };
#
#  programs.direnv = {
#    enable = true;
#    nix-direnv.enable = true;
#  };
#
#  programs.vim = {
#    enable = true;
#    extraConfig = ''
#      if $INSIDE_EMACS == "vterm"
#        silent! !vterm_printf "51;Eevil-emacs-state"
#        autocmd VimLeave * :!vterm_printf "51;Eevil-insert-state"
#      endif
#
#      set number
#      set relativenumber
#      syntax enable
#    '';
#  };
#
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
