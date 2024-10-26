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
      ./patches/xwidget.patch # fixes issue with org-modern and vertical scrolling; upstreamed
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
          ./patches/elfeed-collide-links.patch
          ./patches/elfeed-shr.patch
        ];
      })) elfeed-org

      vterm
      pdf-tools
      direnv

      evil evil-collection evil-snipe
      (evil-org.overrideAttrs(prev: rec {
        src = fetchFromGitHub {
          owner = "doomelpa";
          repo = "evil-org-mode";
          rev = "06518c65ff4f7aea2ea51149d701549dcbccce5d";
          sha256 = "sha256-3li3Y1kyof6+i2qgHxDtfA8KQWPw6tPSbc1vjGpUI4c=";
        };
        patchPhase = ''
          echo ";; Local Variables:" >> evil-org.el
          echo ";; no-native-compile: t" >> evil-org.el
          echo ";; no-byte-compile: t" >> evil-org.el
          echo ";; End:" >> evil-org.el
        '';
      }))

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

      org org-contrib org-modern org-pdftools ox-hugo engrave-faces
      (trivialBuild rec {
        pname = "ob-mathematica";
        version = "b358d4e55705a00162d7615ae7594235da7b2e4e";
        src = fetchFromGitHub {
          owner = "tririver";
          repo = pname;
          rev = version;
          sha256 = "sha256-NvYFTMAeTTW/5Ti89LdXqdDf+ZaaH8tOBjtQlx5+dG4=";
        };
        patches = [ ./patches/ob-mathematica.diff ];
      })
      # probably not keeping all of these...
      org-roam org-roam-bibtex org-roam-ui org-roam-timestamps org-roam-ql
      haskell-mode
      markdown-mode
      (nix-mode.overrideAttrs (prev: {
        patches = (prev.patches or []) ++ [ (pkgs.fetchpatch {
          name = "flake-shebangs.patch";
          url = "https://patch-diff.githubusercontent.com/raw/NixOS/nix-mode/pull/196.patch";
          sha256 = "7APlOE23wxRG26XU2h4kUQn+jmg+PlV3/5bRuMdDnGQ=";
        }) ];
      }))
      (verilog-ts-mode.overrideAttrs (prev: rec {
        version = "0.2.1";
        src = fetchFromGitHub {
          owner = "gmlarumbe";
          repo = prev.pname;
          rev = "refs/tags/v${version}";
          sha256 = "Vrk8MYiqsyln3xIdQiAKKcYMkzc4HO5mQRT1zpQPF+k=";
        };
      }))
      swift-mode
      terraform-mode
      zig-mode
      yaml-mode
      ledger-mode
      wolfram-mode
      sage-shell-mode ob-sagemath
      # this seems to blow up the hm closure size... see NixOS/nix#4119
      # treesit-grammars.with-all-grammars
      (treesit-grammars.with-grammars (_: builtins.attrValues (pkgs.tree-sitter.builtGrammars // {
        tree-sitter-verilog = pkgs.tree-sitter.buildGrammar {
          language = "tree-sitter-verilog";
          version = "0.0.0+rev=0dacb91";
          src = pkgs.fetchFromGitHub {
            owner = "gmlarumbe";
            repo = "tree-sitter-systemverilog";
            rev = "0dacb911daa9614a7c7e79a594d4cb9f478e6554";
            sha256 = "WATrVeP3c//tWLG8VibXZrYrChBs7d4V6LCcEGcofdg=";
          };
          meta.homepage = "https://github.com/gmlarumbe/tree-sitter-systemverilog";
        };
      })))
      # tree-sitter
      # eglot

      all-the-icons
      (all-the-icons-completion.overrideAttrs (prev: {
        patches = (prev.patches or []) ++ [ (pkgs.fetchpatch {
          name = "marginalia.patch";
          url = "https://patch-diff.githubusercontent.com/raw/iyefrat/all-the-icons-completion/pull/33.patch";
          sha256 = "B0rG0Wxacns1iUEFzyIK2fjDxFqnj1k+OgqKTqtQXOI=";
        }) ];
      }))

      kind-icon
      marginalia
      doom-themes solaire-mode
      (doom-modeline.overrideAttrs (prev: rec {
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
      ../../../../bin/emacsclient -c -a "" "$@"
    '';
    emacs = pkgs.symlinkJoin {
      name = "emacs-wrapped";
      paths = [ finalPackage emacsclient ];
      nativeBuildInputs = [
        # (pkgs.makeDarwinBundle {
        #   name = "Emacsclient";
        #   exec = "emacsclientWithArgs";
        #   icon = ./emacs.icns;
        # })

        (pkgs.substitute {
          src = (pkgs.makeDarwinBundle {
            name = "Emacsclient";
            exec = "emacsclientWithArgs";
            icon = ./emacs.icns;
          });
          substitutions = [
            "--replace-fail"
            ''Args"''
            ''Args" "${lib.removeSuffix ".icns" ./emacs.icns}" "${lib.boolToString true}"''
          ];
        })
      ];
      postBuild = "makeDarwinBundlePhase";
    };
  in [ emacs ];
}
