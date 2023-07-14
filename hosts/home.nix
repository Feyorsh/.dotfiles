{ config, lib, pkgs, user, ... }: {
  fonts.fontconfig.enable = true;
  home = {
    username = "ghuebner";
    homeDirectory = "/home/ghuebner";

    packages = with pkgs; [
      neovim
      brightnessctl
      wezterm
      kitty
      firefox-wayland # deprecated

      #emacs29-pgtk
      ((emacsPackagesFor emacs29-pgtk).emacsWithPackages (epkgs: [ epkgs.vterm epkgs.pdf-tools ]))
      aspell
      aspellDicts.en

      brave
      spotify
      playerctl
      slurp
      grim

      # fonts
      (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
      source-sans-pro
      sarasa-gothic
      jetbrains-mono
      twitter-color-emoji
      emacs-all-the-icons-fonts

      pinentry

      zig
      python312
      nodePackages.pyright

      openshift
    ];


    pointerCursor = {
      gtk.enable = true;
      name = "macOS-Monterey";
      package = pkgs.apple-cursor;
      size = 16;
    };
    stateVersion = "23.05";

    # I'm not symlinking this, because init.el should exist independently of HM and Nix
    #file.".config/emacs".source = config.lib.file.mkOutOfStoreSymlink ../config/emacs;

    # https://github.com/python-poetry/poetry/issues/5929
    file.".config/fish/completions/poetry.fish".source = config.lib.file.mkOutOfStoreSymlink config.home.homeDirectory + /.dotfiles/config/fish/completions/poetry.fish;
  };
  programs.home-manager.enable = true;

  services.playerctld.enable = true;
  #programs.emacs = {
  # enable = true;
  # extraPackages = epkgs: [ epkgs.emacs-libvterm epkgs.pdf-tools ];
  #};

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
      # this currently prints up to and _including_ the "sentinel" package.
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
    ];
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

  programs.gpg = {
    enable = true;
    mutableKeys = true;
    mutableTrust = true;
  };
  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "tty";
    #extraConfig = '' pinentry-program ${pkgs.pinentry-rofi.outPath} '';
  };


  nixpkgs.config = {
    allowUnfree = true;
  };
  gtk = {
    enable = true;
    theme = {
      name = "Tokyonight-Dark-BL";
      package = pkgs.tokyo-night-gtk;
    };
#   iconTheme = {
#     name = "MoreWaita";
#     package = pkgs.morewaita-icon-theme;
#   };
    #font = {
      #name = "FiraCode Nerd Font Mono Medium";
    #};
  };
}
