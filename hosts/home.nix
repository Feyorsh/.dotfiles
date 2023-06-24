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
  };
  programs.home-manager.enable = true;

  services.playerctld.enable = true;
  #programs.emacs = {
  # enable = true;
  # extraPackages = epkgs: [ epkgs.emacs-libvterm epkgs.pdf-tools ];
  #};

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      direnv hook fish | source

      if begin; [ -n "$INSIDE_EMACS" ] ; end
         fish_default_key_bindings
      else
        fish_vi_key_bindings
      end
    '';
    plugins = [
      { name = "pure"; src = pkgs.fishPlugins.pure.src; }
    ];
  };
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
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
#     name = "Papirus-Dark";
#     package = pkgs.papirus-icon-theme;
#   };
    #font = {
      #name = "FiraCode Nerd Font Mono Medium";
    #};
  };
}
