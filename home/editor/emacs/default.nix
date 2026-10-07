{ config, lib, pkgs, ... }:
let
  inherit (pkgs) fetchFromGitHub fetchFromGitea fetchpatch;
  emacs' = pkgs.emacs30-macport.overrideAttrs (prev: {
    patches = (prev.patches or []) ++ [
      (fetchpatch {
        name = "no-titlebar.patch";
        url = "https://raw.githubusercontent.com/railwaycat/homebrew-emacsmacport/b825bfdd1a25883715034e4abef4f7ad871e604f/patches/emacs-26.2-rc1-mac-7.5-no-title-bar.patch";
        hash = "sha256-f2DRcUZq8Y18n6MJ6vtChN5hLGERduMB8B1mrrds6Ns=";
      })
      (fetchpatch {
        name = "fix-yabai-tiling.patch";
        url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/61d588ce80fb4282e107f5ab97914e32451c3da1/patches/emacs-28/fix-window-role.patch";
        hash = "sha256-+z/KfsBm1lvZTZNiMbxzXQGRTjkCFO4QPlEK35upjsE=";
      })
    ];

    postPatch = prev.postPatch + ''
      substituteInPlace lisp/gnus/smime.el --replace-fail '(car (gnutls-trustfiles))' '"/etc/ssl/certs/ca-certificates.crt"'
    '';

    preConfigure = ''
      configureFlagsArray+=(
        "CFLAGS=-DFD_SETSIZE=10000 -DDARWIN_UNLIMITED_SELECT"
      )
    '';
  });

  emacsWrapped = let
    emacsWithPackages = let epkgs = pkgs.emacsPackagesFor config.programs.emacs.package;
                        in (epkgs.overrideScope config.programs.emacs.overrides).emacsWithPackages;
    final = emacsWithPackages config.programs.emacs.extraPackages;
  in
    pkgs.symlinkJoin {
      name = "emacs";
      paths = [ final ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      # incredibly cursed setup: this ensures emacsclient starts up the server if it isn't running (the path to emacs is important because of pathing), suppresses output unless something is being evaled, and that it doesn't create a new frame if run from within emacs.
      postBuild = ''
        rm $out/bin/emacsclient
        makeWrapper $out/bin/.emacsclient-wrapped $out/bin/emacsclient --set _c '-c' --add-flags ' ''${_c/''${INSIDE_EMACS:+*}/} ''${ [[ " $@ " != *" -e "* && " $@ " != *" --eval "* ]] && echo "-u"; } -a $out/Applications/Emacs.app/Contents/MacOS/Emacs'

        rm $out/share/info
        mkdir -p $out/share/info
        ln -s ${final}/share/info/* $out/share/info/
        find ${final.deps}/share -regex '.*\.\(info\|info\.gz\)' -exec ln -sf '{}' $out/share/info/ \;
      '';
    };
in
{
  programs.emacs = {
    enable = false; # intentional
    package = emacs';
    extraPackages =
      epkgs:
      (
        with epkgs;
        [
          erc
          erc-hl-nicks
          insert-kaomoji
          (ement.override {
            taxy-magit-section = taxy-magit-section.overrideAttrs (prev: {
              patches = (prev.patches or [ ]) ++ [ ./patches/taxy-framep.patch ];
              patchPhase = ''
                runHook prePatch
                mkdir tmp-untar-dir
                pushd tmp-untar-dir

                tar --extract --verbose --file=$src
                content_directory=${prev.pname}-${prev.version}
                patch -d $content_directory < $patches
                src=$PWD/$content_directory.tar
                tar --create --verbose --file=$src $content_directory

                popd
                runHook postPatch
              '';
            });
          })

          (elfeed.overrideAttrs (prev: {
            patches = (prev.patches or [ ]) ++ [
              ./patches/elfeed-collide-links.patch
            ];
          }))
          elfeed-web
          elfeed-org

          emms
          pkgs.mpv
          pkgs.imagemagick
          pkgs.python315Packages.tinytag

          persistent-scratch
          vterm
          (tramp-rpc.override {
            archs = with pkgs.pkgsCross; [
              musl64
              aarch64-multiplatform-musl
              aarch64-darwin
            ];
          })

          (trivialBuild rec {
            pname = "comint-fold";
            version = "0.1.0";
            src = fetchFromGitHub {
              owner = "jdtsmith";
              repo = pname;
              rev = "9b9f2bbc762c846bf328e698413391db149cc759";
              hash = "sha256-PCI5pLbIConHaOehMmfgZAnEXM1jLS+Rjs8TPKe5wuw=";
            };
          })

          pdf-tools
          nov
          # for doc-view
          pkgs.libreoffice-bin pkgs.mupdf-headless pkgs.ghostscript_headless

          envrc
          restclient
          elpher
          disaster
          pkgs.zig_0_13
          dape
          docker
          pkgs.colima
          pkgs.docker
          pkgs.docker-compose
          deadgrep
          wgrep wgrep-deadgrep
          dumb-jump
          casual

          evil
          evil-snipe
          evil-visualstar
          evil-numbers
          evil-surround
          evil-collection
          (evil-org.overrideAttrs (prev: {
            src = fetchFromGitHub {
              owner = "doomelpa";
              repo = "evil-org-mode";
              rev = "06518c65ff4f7aea2ea51149d701549dcbccce5d";
              hash = "sha256-3li3Y1kyof6+i2qgHxDtfA8KQWPw6tPSbc1vjGpUI4c=";
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
          cape
          vertico
          orderless
          consult
          consult-dir
          embark
          embark-consult
          prescient

          gcmh
          vlf
          helpful
          devdocs

          (trivialBuild rec {
            pname = "org";
            version = "9.7.39-git";
            src = fetchFromGitea {
              domain = "code.tecosaur.net";
              owner = "tec";
              repo = "org-mode";
              rev = "1ef59f0aa02e3cff40bae68b756a29bc2001739e";
              hash = "sha256-kPVFT2fgoOO5aCCAifzlSwDhMR2RqhhT1akOKfRyalw=";
              forceFetchGit = true;
            };
            buildPhase = ''
              emacs -batch -Q -L lisp -l ../mk/org-fixup \
                --eval '(progn (setq org-fake-release "${version}" org-fake-git-version "${version}-fake") (org-make-autoloads))'
            '';
            preInstall = "cd lisp";
          })
          org-contrib
          ox-clip
          org-modern
          (trivialBuild rec {
            pname = "org-modern-indent";
            version = "0.5.1";
            src = fetchFromGitHub {
              owner = "jdtsmith";
              repo = pname;
              rev = "refs/tags/v${version}";
              hash = "sha256-st3338Jk9kZ5BLEPRJZhjqdncMpLoWNwp60ZwKEObyU=";
            };
            packageRequires = [
              org
              compat
            ];
          })
          org-pdftools
          engrave-faces
          (ox-hugo.overrideAttrs (prev: {
            patchPhase = ''
              for f in ./*.el; do
                  echo ";; Local Variables:" >> $f
                  echo ";; no-native-compile: t" >> $f
                  echo ";; no-byte-compile: t" >> $f
                  echo ";; End:" >> $f
              done
            '';
          }))
          (trivialBuild rec {
            pname = "ob-mathematica";
            version = "b358d4e55705a00162d7615ae7594235da7b2e4e";
            src = fetchFromGitHub {
              owner = "tririver";
              repo = pname;
              rev = version;
              hash = "sha256-NvYFTMAeTTW/5Ti89LdXqdDf+ZaaH8tOBjtQlx5+dG4=";
            };
            patches = [ ./patches/ob-mathematica.diff ];
          })
          citar
          citar-embark
          # probably not keeping all of these...
          org-roam
          org-roam-bibtex
          org-roam-ui
          org-roam-timestamps
          org-roam-ql
          citar-org-roam

          auctex
          cdlatex
          mathjax
          pkgs.nodejs
          yasnippet
          yasnippet-capf
          sis
          package-lint-flymake

          # prog-modes
          python-mls
          haskell-mode consult-hoogle
          dhall-mode
          markdown-mode
          (nix-mode.overrideAttrs (prev: {
            patches = (prev.patches or [ ]) ++ [
              (fetchpatch {
                name = "flake-shebangs.patch";
                url = "https://patch-diff.githubusercontent.com/raw/NixOS/nix-mode/pull/196.patch";
                hash = "sha256-7APlOE23wxRG26XU2h4kUQn+jmg+PlV3/5bRuMdDnGQ=";
              })
            ];
          }))
          nix-update pkgs.nix-prefetch-git
          verilog-ts-mode
          swift-mode
          terraform-mode
          zig-mode
          yaml-mode
          wolfram-mode
          sage-shell-mode
          ob-sagemath
          ob-elixir
          typst-ts-mode
          julia-mode
          julia-ts-mode
          julia-vterm
          ob-julia-vterm
          eglot-jl
          nasm-mode
          vimrc-mode
          meson-mode

          eglot
          eldoc-mouse
          apheleia
          editorconfig

          # treesit-grammars.with-all-grammars seems to blow up the hm closure size... see NixOS/nix#4119
          (treesit-grammars.with-grammars (
            grammars:
            [
            ]
            ++ (builtins.attrValues (
              pkgs.tree-sitter.builtGrammars
              // {
                tree-sitter-verilog = pkgs.tree-sitter.buildGrammar {
                  language = "tree-sitter-verilog";
                  version = "0.0.0+rev=0dacb91";
                  src = fetchFromGitHub {
                    owner = "gmlarumbe";
                    repo = "tree-sitter-systemverilog";
                    rev = "0dacb911daa9614a7c7e79a594d4cb9f478e6554";
                    hash = "sha256-WATrVeP3c//tWLG8VibXZrYrChBs7d4V6LCcEGcofdg=";
                  };
                  meta.homepage = "https://github.com/gmlarumbe/tree-sitter-systemverilog";
                };
              }
            ))
          ))
          treesit-fold

          nerd-icons
          nerd-icons-dired
          nerd-icons-ibuffer
          nerd-icons-corfu
          nerd-icons-completion

          marginalia
          doom-themes solaire-mode doom-modeline
          rainbow-mode
          diff-hl difftastic

          ultra-scroll
        ]
      );
  };

  home.packages = [
    emacsWrapped
    pkgs.nerd-fonts.symbols-only
  ];

  home.sessionVariables = {
    EDITOR = "emacsclient";
  };

  programs.fish = {
    interactiveShellInit = lib.mkAfter ''
      # for stuff that needs to work in other terminal emulators too, not just vterm
      if begin; [ -n "$INSIDE_EMACS" ]; end
         fish_default_key_bindings
      end

      if string match -qr "vterm" $INSIDE_EMACS
         source ${pkgs.emacsPackages.vterm}/**/emacs-vterm.fish

         function emacs
             vterm_find_file "$argv"
         end
         function man
             vterm_cmd man (string join " " -- "-l" (command man -w "$argv" 2>/dev/null))
         end
         alias ff='vterm_find_file'
      end
    '';
    shellAliases = {
      ff = "vterm_find_file";
      ee = "open -a ${emacsWrapped}/Applications/Emacs.app";
      emacs = ''
        if begin; [ -n "$INSIDE_EMACS" ]; end
            vterm_find_file "$argv"
        else
            command emacs "$argv"
        end
      '';
    };
    functions = {
      ee = "open -a ${emacsWrapped}/Applications/Emacs.app";
    };
  };
}
