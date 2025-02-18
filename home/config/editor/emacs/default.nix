{ config, lib, pkgs, ... }:
let
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
    preConfigure = ''
      configureFlagsArray+=(
        "CFLAGS=-DFD_SETSIZE=10000 -DDARWIN_UNLIMITED_SELECT"
      )
    '';


    buildInputs = (prev.buildInputs or []) ++ [
      pkgs.darwin.apple_sdk_11_0.frameworks.WebKit
    ];
  });

  emacsWrapped = let
    emacsWithPackages = let epkgs = pkgs.emacsPackagesFor config.programs.emacs.package;
                        in (epkgs.overrideScope config.programs.emacs.overrides).emacsWithPackages;
    final = emacsWithPackages config.programs.emacs.extraPackages;
  in
    pkgs.symlinkJoin {
      name = "emacs";
      paths = [ final ];
      nativeBuildInputs = [
        # (pkgs.substitute {
        #   src = (pkgs.makeDarwinBundle {
        #     name = "emacsclient";
        #     exec = "emacsclient";
        #     icon = "Emacs.icns";
        #   });
        #   substitutions = [
        #     "--replace-fail"
        #     ''"emacsclient" "emacsclient"''
        #     ''"emacsclient" "emacsclient" "Emacs" "${lib.boolToString true}"''
        #   ];
        # })
        pkgs.makeWrapper
      ];
      # incredibly cursed setup: this ensures emacsclient starts up the server if it isn't running (the path to emacs is important because of pathing) and that it doesn't create a new frame if run from within emacs.
      postBuild = ''
        # rm $out/Applications/Emacs.app/Contents/MacOS/Emacs
        # makeWrapper $out/bin/emacsclient $out/Applications/Emacs.app/Contents/MacOS/Emacs --inherit-argv0 --add-flags "-c -a $out/Applications/Emacs.app/Contents/MacOS/.Emacs-wrapped"
        rm $out/bin/emacsclient
        makeWrapper $out/bin/.emacsclient-wrapped $out/bin/emacsclient --set _t "-c" --add-flags "\"\''${_t/\''${INSIDE_EMACS:+*}/-u}\" -a $out/Applications/Emacs.app/Contents/MacOS/Emacs"

        rm $out/Applications/Emacs.app/Contents/Resources/Emacs.icns
        cp ${./emacs.icns} $out/Applications/Emacs.app/Contents/Resources/Emacs.icns
      '';
    };
in
{
  imports = [ ../../mail ];

  home.packages = [ emacsWrapped ];

  home.sessionVariables = {
    EDITOR = "emacsclient";
  };

  programs.emacs = {
    enable = false; # intentional
    package = emacs';
    extraPackages = epkgs: with pkgs; ((with epkgs; [
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
      restclient
      disaster

      evil evil-snipe evil-visualstar evil-numbers
      (evil-collection.overrideAttrs {
        patches = [(fetchpatch {
          url = "https://github.com/emacs-evil/evil-collection/commit/05731c551be8cdda40ae6479adfb30b7e9c7fe39.patch";
          hash = "sha256-QAYIVyj5bmBNItiLn7ObeAY+aup13xX6ahv9TZ5+7sg=";
          revert = true;
        })];
      })
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
      corfu cape
      vertico
      orderless
      consult
      embark embark-consult
      which-key # added to emacs 30; just using for embark!
      prescient

      gptel

      gcmh
      helpful
      devdocs

      (trivialBuild rec {
        pname = "org";
        version = "9.7.18-git";
        src = fetchFromGitea {
          domain = "code.tecosaur.net";
          owner = "tec";
          repo = "org-mode";
          rev = version;
          hash = "sha256-KcBjdo+WWnwXdYGkF0seuvuuc1edaG6TM9e14TG7Brg=";
          forceFetchGit = true;
        };
        buildPhase = ''
          emacs -batch -Q -L lisp -l ../mk/org-fixup \
            --eval '(progn (setq org-fake-release "${version}" org-fake-git-version "${version}-fake") (org-make-autoloads))'
        '';
        preInstall = "cd lisp";
      })
      org-contrib org-modern org-pdftools engrave-faces
      (ox-hugo.overrideAttrs(prev: rec {
        patchPhase = ''
          for f in ./*.el; do
              echo ";; Local Variables:" >> $f
              echo ";; no-native-compile: t" >> $f
              echo ";; no-byte-compile: t" >> $f
              echo ";; End:" >> $f
          done
        '';
      })) ox-clip
      (trivialBuild rec {
        pname = "ob-mathematica";
        version = "b358d4e55705a00162d7615ae7594235da7b2e4e";
        src = fetchFromGitHub {
          owner = "tririver";
          repo = pname;
          rev = version;
          sha256 = "NvYFTMAeTTW/5Ti89LdXqdDf+ZaaH8tOBjtQlx5+dG4=";
        };
        patches = [ ./patches/ob-mathematica.diff ];
      })
      # probably not keeping all of these...
      org-roam org-roam-bibtex org-roam-ui org-roam-timestamps org-roam-ql
      auctex cdlatex
      yasnippet yasnippet-capf

      # prog-modes
      jedi # python
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
      # treesit-grammars.with-all-grammars seems to blow up the hm closure size... see NixOS/nix#4119
      (treesit-grammars.with-grammars (grammars: [
      ] ++ (builtins.attrValues (pkgs.tree-sitter.builtGrammars // {
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
      }))))
      (trivialBuild rec {
        pname = "typst-ts-mode";
        version = "42094eb2508f30ca2aba26786768e969476d98fa";
        src = fetchFromGitea {
          domain = "codeberg.org";
          owner = "meow_king";
          repo = pname;
          rev = version;
          sha256 = "KYIu7nOhfeNoypOleFXzKiUm9yF/6MFQXUZllSyDiKw=";
        };
      })
      (julia-ts-mode.overrideAttrs (prev: {
        src = fetchFromGitHub {
          owner = "JuliaEditorSupport";
          repo = "julia-ts-mode";
          rev = "d693c6b35d3aed986b2700a3b5f910de12d6c53c";
          sha256 = "sha256-bG2v3lWFkrDrGYF6RYJhE6/bS7oeOdHKFUtRgk1L5Uk=";
        };
      }))
      julia-mode julia-vterm ob-julia-vterm

      all-the-icons
      (all-the-icons-completion.overrideAttrs (prev: {
        packageRequires = (prev.packageRequires or []) ++ [
          epkgs.compat
        ];
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
      }))
      rainbow-mode

      (trivialBuild rec {
        pname = "ultra-scroll";
        version = "0.3.2";
        src = fetchFromGitHub {
          owner = "jdtsmith";
          repo = pname;
          rev = "2c517bf9b61bf432f706ff8a585ba453c7476be2";
          hash = "sha256-U2QTbxkch/oGdXXnzf2EPX3Ga3VYmQlnjC/JKBq5DEI=";
        };
      })
    ]) ++ [
      nixfmt-rfc-style
      shellcheck

      # LSP
      clang-tools
      pyright # really annoying in practice; need to raise fd limit
      # pkgs.sourcekit-lsp # swift
      # nil # nix
      # zls # zig
      # gopls # go
    ]);
  };

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
