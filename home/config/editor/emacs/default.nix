{ config, lib, pkgs, ... }:
let
  aspell = with pkgs; (aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]));
  emacs' = pkgs.emacs29-macport.overrideAttrs (prev: {
    patches = (prev.patches or []) ++ [
      (pkgs.fetchpatch {
        name = "no-titlebar.patch";
        url = "https://raw.githubusercontent.com/railwaycat/homebrew-emacsmacport/b825bfdd1a25883715034e4abef4f7ad871e604f/patches/emacs-26.2-rc1-mac-7.5-no-title-bar.patch";
        sha256 = "f2DRcUZq8Y18n6MJ6vtChN5hLGERduMB8B1mrrds6Ns=";
      })

      (pkgs.fetchpatch {
        name = "fix-yabai-tiling.patch";
        url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/61d588ce80fb4282e107f5ab97914e32451c3da1/patches/emacs-28/fix-window-role.patch";
        sha256 = "+z/KfsBm1lvZTZNiMbxzXQGRTjkCFO4QPlEK35upjsE=";
      })
    ];

    configureFlags = (prev.configureFlags or []) ++ [
      "--with-xwidgets"
    ];

    buildInputs = (prev.buildInputs or []) ++ [
      pkgs.darwin.apple_sdk_11_0.frameworks.WebKit
    ];
  });
in
{
  imports = [ ../../mail ];

  programs.emacs.enable = false; # this is intentional
  programs.emacs.package = emacs';
  programs.emacs.extraPackages = epkgs: with pkgs; ((with epkgs; [
      erc erc-hl-nicks
      insert-kaomoji
      ement
      (elfeed.overrideAttrs(prev: rec {
        patches = (prev.patches or []) ++ [
          ./elfeed-collide-links.patch
          ./elfeed-shr.patch
        ];
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

        # I forgot why I put this here... eglot maybe?
        # patches = (prev.patches or []) ++ [ (fetchpatch {
        #   url = "https://github.com/seagle0128/doom-modeline/commit/9773ef765b5d530e9f6657bc24efb83059a3d888.patch";
        #   sha256 = "sha256-vNqz3bD+E4XhxIsddAlOqyUnf9RsnZWkpWhJIqzav6Q=";
        # }) ];
      }))
      rainbow-mode
    ]) ++ [
      clang-tools
      pyright
      # pkgs.sourcekit-lsp # swift
      # nil # nix
      # zls # zig
      # gopls # go
    ]);


  home.file.".aspell.conf".text = "data-dir ${aspell}/lib/aspell";

  home.packages = let
    emacsWithPackages = let epkgs = pkgs.emacsPackagesFor config.programs.emacs.package;
                    in (epkgs.overrideScope config.programs.emacs.overrides).emacsWithPackages;
    finalPackage = emacsWithPackages config.programs.emacs.extraPackages;

    emacsclient = pkgs.writeShellScriptBin "emacsclientWithArgs" ''
      ./emacsclient -c -a "" "$@"
    '';
    emacs = pkgs.symlinkJoin {
      name = "emacs-wrapped";
      paths = [ finalPackage emacsclient ];
      nativeBuildInputs = [
        (pkgs.makeDarwinBundle {
          name = "Emacsclient";
          exec = "emacsclientWithArgs";
          icon = ./emacs.icns;
        })
      ];
      postBuild = "makeDarwinBundlePhase";
    };
  in [ emacs ];
}
