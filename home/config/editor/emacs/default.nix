{ pkgs, lib, ... }:
let
  aspell = with pkgs; (aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]));
  emacs' = pkgs.emacs29-macport.overrideAttrs (prev: {
    patches = (prev.patches or []) ++ [
      # match title bar color to theme
      # (pkgs.fetchpatch {
      #   url = "https://raw.githubusercontent.com/railwaycat/homebrew-emacsmacport/911412ca8ea2671c1122bc307a1cd0740005a55d/patches/emacs-mac-title-bar-9.1.patch";
      #   sha256 = "+SGySdRPFuw+yOuTwGiH4tLYqk4bh+2BRT46jUGEfuY=";
      # })
      (pkgs.fetchpatch {
        url = "https://raw.githubusercontent.com/railwaycat/homebrew-emacsmacport/b825bfdd1a25883715034e4abef4f7ad871e604f/patches/emacs-26.2-rc1-mac-7.5-no-title-bar.patch";
        sha256 = "f2DRcUZq8Y18n6MJ6vtChN5hLGERduMB8B1mrrds6Ns=";
      })
      (pkgs.fetchpatch {
        url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/61d588ce80fb4282e107f5ab97914e32451c3da1/patches/emacs-28/fix-window-role.patch";
        sha256 = "+z/KfsBm1lvZTZNiMbxzXQGRTjkCFO4QPlEK35upjsE=";
      })
    ];

    configureFlags = (prev.configureFlags or []) ++ [
      "--with-xwidgets"
      # tried to fix the FD problem; alas.
      # ''CFLAGS="-DFD_SETSIZE=10000 -DDARWIN_UNLIMITED_SELECT"''
    ];

    buildInputs = (prev.buildInputs or []) ++ [
      pkgs.darwin.apple_sdk_11_0.frameworks.WebKit
    ];
  }); #.override({ withXwidgets = true; }); # assert in nixpkgs that doesn't need to be there
in
{
  imports = [ ../../mail ];

  home.packages = with pkgs; [
    ((emacsPackagesFor emacs').emacsWithPackages (epkgs: (with epkgs; [
      # goddammt. Ok fine, we'll split between config.org and home manager (it's fucking ugly though).
      # the idea here is to install the really important and long-lived packages through nix, which as an added bonus allows me to patch them easily.
      # *in theory* I can still use straight-use-package on the fly
      mu4e
      # broken; check back later ; org-msg

      erc erc-hl-nicks
      insert-kaomoji
      ement
      (elfeed.overrideAttrs(prev: rec {
        # patches = (prev.patches or []) ++ [ ./config/emacs/elfeed.patch ./config/emacs/elfeed-shr.patch ];
      })) elfeed-org

      vterm
      pdf-tools
      (magit.overrideAttrs(prev: rec {
        patches = (prev.patches or []) ++ [
          (fetchpatch {
            url = "https://github.com/magit/magit/commit/f31cf79b2731765d63899ef16bc8be0fa2cc7d32.patch";
            sha256 = "sha256-1UClOoJ+M33dzmmq2HgM31mNxtczjw+ekL5GuXBF3d4=";
          })
        ];
      })) forge
      direnv

      evil evil-collection evil-org evil-snipe
      general
      corfu
      vertico
      orderless
      consult
      embark embark-consult
      prescient

      gcmh
      helpful
      jinx

      org org-modern org-pdftools ox-hugo engrave-faces
      # probably not keeping all of these...
      org-roam org-roam-bibtex org-roam-ui org-roam-timestamps org-roam-ql
      haskell-mode
      markdown-mode
      nix-mode
      swift-mode
      terraform-mode
      zig-mode
      yaml-mode
      ledger-mode
      wolfram-mode
      sage-shell-mode ob-sagemath
      treesit-grammars.with-all-grammars
      # eglot

      all-the-icons all-the-icons-completion
      kind-icon
      marginalia
      doom-themes solaire-mode
      (doom-modeline.overrideAttrs(prev: rec {
        version = "3.4.0";
        src = fetchFromGitHub {
          owner = "seagle0128";
          repo = prev.pname;
          rev = "refs/tags/v${version}";
          sha256 = "sha256-cTaMtLzolZckTsCzYT1Ij/ESvw+f+QI0jFKfPYbFrPw=";
        };

        # patches = (prev.patches or []) ++ [ (fetchpatch {
        #   url = "https://github.com/seagle0128/doom-modeline/commit/9773ef765b5d530e9f6657bc24efb83059a3d888.patch";
        #   sha256 = "sha256-vNqz3bD+E4XhxIsddAlOqyUnf9RsnZWkpWhJIqzav6Q=";
        # }) ];
      }))
      rainbow-mode
    ]) ++ [
      # for some reason, LSP servers don't play nice with `emacsWithPackages`.
      clang-tools
      pyright
      # pkgs.sourcekit-lsp # swift
      # nil # nix
      # zls # zig
      # gopls # go
    ]))
    ledger

    pass
    
    aspell
  ];

  home.file.".aspell.conf".text = "data-dir ${aspell}/lib/aspell";
}
