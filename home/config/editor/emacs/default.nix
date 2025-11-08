{ config, lib, pkgs, ... }:
let
  inherit (pkgs) fetchFromBitbucket fetchFromGitHub fetchFromGitea fetchpatch;
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

    configureFlags = (prev.configureFlags or []) ++ [
      "--with-xwidgets"
      "--with-librsvg"
    ];
    preConfigure = ''
      configureFlagsArray+=(
        "CFLAGS=-DFD_SETSIZE=10000 -DDARWIN_UNLIMITED_SELECT"
      )
    '';

    buildInputs = (prev.buildInputs or []) ++ [
      pkgs.librsvg
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
      nativeBuildInputs = [ pkgs.makeWrapper ];
      # incredibly cursed setup: this ensures emacsclient starts up the server if it isn't running (the path to emacs is important because of pathing) and that it doesn't create a new frame if run from within emacs.
      postBuild = ''
        # rm $out/Applications/Emacs.app/Contents/MacOS/Emacs
        # makeWrapper $out/bin/emacsclient $out/Applications/Emacs.app/Contents/MacOS/Emacs --inherit-argv0 --add-flags "-c -a $out/Applications/Emacs.app/Contents/MacOS/.Emacs-wrapped"
        rm $out/bin/emacsclient
        makeWrapper $out/bin/.emacsclient-wrapped $out/bin/emacsclient --set _t "-c" --add-flags "\"\''${_t/\''${INSIDE_EMACS:+*}/-u}\" -a $out/Applications/Emacs.app/Contents/MacOS/Emacs"

        rm $out/Applications/Emacs.app/Contents/Resources/Emacs.icns
        cp ${./emacs.icns} $out/Applications/Emacs.app/Contents/Resources/Emacs.icns

        rm $out/share/info
        mkdir -p $out/share/info
        ln -s ${final}/share/info/* $out/share/info/
        find ${final.deps}/share -regex '.*\.\(info\|info\.gz\)' -exec ln -sf '{}' $out/share/info/ \;
      '';
    };
in
{
  imports = [ ../../mail ];

  programs.emacs = {
    enable = false; # intentional
    package = emacs';
    extraPackages = epkgs: (with epkgs; [
      erc erc-hl-nicks
      insert-kaomoji
      (ement.override {
        taxy-magit-section = taxy-magit-section.overrideAttrs(prev: {
          patches = (prev.patches or []) ++ [ ./patches/taxy-framep.patch ];
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
      }) # pkgs.pantalaimon
      (elfeed.overrideAttrs(prev: {
        patches = (prev.patches or []) ++ [
          ./patches/elfeed-collide-links.patch
          ./patches/elfeed-shr.patch
        ];
      })) elfeed-org
      emms
      (pkgs.mpv.overrideAttrs (prev: {
        patches = (prev.patches or []) ++ [ (fetchpatch {
          url = "https://patch-diff.githubusercontent.com/raw/mpv-player/mpv/pull/15115.patch";
          hash = "sha256-3iaD2t/bzzlo6FFcPac/bPuVg5adbBFPI3HUeXysRrc=";
        }) ];
      })) pkgs.spotifyd pkgs.imagemagick pkgs.python312Packages.tinytag

      persistent-scratch
      dirvish
      vterm
      shx
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
      pdf-tools nov
      envrc
      restclient
      disaster pkgs.zig_0_13
      dape
      docker pkgs.colima pkgs.docker pkgs.docker-compose
      deadgrep

      evil evil-snipe evil-visualstar evil-numbers evil-surround
      evil-collection
      (evil-org.overrideAttrs(prev: {
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
      corfu cape
      vertico
      orderless
      consult
      embark embark-consult
      prescient

      gptel
    ] ++ (let
      withEmbark = true;
      consult-omni =
        trivialBuild rec {
          pname = "consult-omni";
          version = "0.3-unstable-2025-08-01";
          src = fetchFromGitHub {
            owner = "armindarvish";
            repo = pname;
            rev = "d0a24058bf0dda823e5f1efcae5da7dc0efe6bda";
            hash = "sha256-dzKkJ+3lMRkHRuwe43wpzqnFvF8Tl6j+6XHUsDhMX4o=";
          };
          postPatch = lib.optionalString (!withEmbark) ''
            rm consult-omni-embark.el
          '';
          postInstall = "cp -r sources $LISPDIR/sources";
          packageRequires = [ consult ] ++ lib.optionals withEmbark [ embark-consult ];
        };
    in [ consult-omni ]) ++ [
      gcmh
      vlf
      helpful
      devdocs

      (trivialBuild rec {
        pname = "org";
        version = "9.7.31-git";
        src = fetchFromGitea {
          domain = "code.tecosaur.net";
          owner = "tec";
          repo = "org-mode";
          rev = "bfecf6658900f3b0f1939627ddf3514ad2e21d90";
          hash = "sha256-uKvI3woYHzKQvl6ReWoHbuFv68n4rdXYpGmE4Gvnf7U=";
          forceFetchGit = true;
        };
        buildPhase = ''
          emacs -batch -Q -L lisp -l ../mk/org-fixup \
            --eval '(progn (setq org-fake-release "${version}" org-fake-git-version "${version}-fake") (org-make-autoloads))'
        '';
        preInstall = "cd lisp";
      })
      org-contrib ox-clip
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
        packageRequires = [ org compat ];
      })
      org-pdftools
      engrave-faces
      (ox-hugo.overrideAttrs(prev: {
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
      # probably not keeping all of these...
      org-roam org-roam-bibtex org-roam-ui org-roam-timestamps org-roam-ql

      auctex cdlatex mathjax pkgs.nodejs
      (trivialBuild rec {
        pname = "overleaf";
        version = "1.1.0";
        src = fetchFromGitHub {
          owner = "vale981";
          repo = "overleaf.el";
          rev = "v${version}";
          hash = "sha256-zDXUWSs8HqUdKYSbtzloXZe51jBmudWXsyhpdBE8lqc=";
        };
        patches = [ (fetchpatch {
          name = "firefox-path.patch";
          url = "https://patch-diff.githubusercontent.com/raw/vale981/overleaf.el/pull/5.patch";
          hash = "sha256-su+enyUKys+d6p9bYL+Ue1G/u3K0EdBA5qNckmc/rA8=";
        }) ];
        packageRequires = [ plz websocket webdriver ];
      }) pkgs.geckodriver
      yasnippet yasnippet-capf
      sis
      package-lint-flymake

      # prog-modes
      python-mls pkgs.ruff pkgs.basedpyright
      haskell-mode
      markdown-mode
      sly paredit
      (nix-mode.overrideAttrs (prev: {
        patches = (prev.patches or []) ++ [ (fetchpatch {
          name = "flake-shebangs.patch";
          url = "https://patch-diff.githubusercontent.com/raw/NixOS/nix-mode/pull/196.patch";
          hash = "sha256-7APlOE23wxRG26XU2h4kUQn+jmg+PlV3/5bRuMdDnGQ=";
        }) ];
      })) pkgs.nixd
      nix-ts-mode
      (trivialBuild {
        pname = "nix3";
        version = "0.1-git";
        src = fetchFromGitHub {
          owner = "emacs-twist";
          repo = "nix3.el";
          rev = "6e8a7c3b2683a0fdae2a968e211c3585580fbca5";
          hash = "sha256-2rg5S/ElHfXFgomnkjkoPjd37jH6c52TsBhNCFvIE+4=";
        };
        packageRequires = [ promise compat magit-section s ];
        preBuild = ''
          mv ./extra/magit-nix3.el .
        '';
      })
      (nix-update.overrideAttrs {
        patches = [
          (fetchpatch {
            url = "https://patch-diff.githubusercontent.com/raw/jwiegley/nix-update-el/pull/14.patch";
            hash = "sha256-uxCdSKzW67c05s1V6NXJsJssncnunAWK7NFHDZatjao=";
          })
          (fetchpatch {
            url = "https://patch-diff.githubusercontent.com/raw/jwiegley/nix-update-el/pull/15.patch";
            hash = "sha256-lXs4V2fMaKvQn+iGvw1TZ90tIGG0pfYTNZn+M8n4fpY=";
          })
        ];
      }) pkgs.nix-prefetch-git
      verilog-ts-mode
      swift-mode pkgs.sourcekit-lsp
      terraform-mode
      zig-mode pkgs.zls
      yaml-mode
      wolfram-mode
      sage-shell-mode ob-sagemath
      ob-elixir
      typst-ts-mode
      julia-mode julia-ts-mode julia-vterm ob-julia-vterm eglot-jl
      nasm-mode
      vimrc-mode
      meson-mode
      # other LSPs
      pkgs.clang-tools pkgs.rust-analyzer pkgs.gopls pkgs.shellcheck

      # treesit-grammars.with-all-grammars seems to blow up the hm closure size... see NixOS/nix#4119
      (treesit-grammars.with-grammars (grammars: [
      ] ++ (builtins.attrValues (pkgs.tree-sitter.builtGrammars // {
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
      })))) treesit-fold

      (trivialBuild rec {
        pname = "eglot-booster";
        version = "0.1.0";
        src = fetchFromGitHub {
          owner = "jdtsmith";
          repo = pname;
          rev = "e6daa6bcaf4aceee29c8a5a949b43eb1b89900ed";
          hash = "sha256-PLfaXELkdX5NZcSmR1s/kgmU16ODF8bn56nfTh9g6bs=";
        };
      }) pkgs.emacs-lsp-booster

      nerd-icons nerd-icons-dired nerd-icons-ibuffer nerd-icons-corfu nerd-icons-completion

      marginalia
      doom-themes solaire-mode doom-modeline
      rainbow-mode
      diff-hl difftastic

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
    ]);
  };

  home.packages = [
    emacsWrapped
    pkgs.nerd-fonts.symbols-only
  ];

  home.sessionVariables = {
    EDITOR = "emacsclient";
  };

  # launchd.agents.pantalaimon = let
  #   config = (pkgs.formats.ini {}).generate "pantalaimon.conf" {
  #     "mozilla-matrix" = {
  #       Homeserver = "https://mozilla.modular.im:443";
  #       ListenAddress = "localhost";
  #       ListenPort = 8009;
  #     };
  #   };
  # in {
  #   enable = true;
  #   config = {
  #     ProgramArguments = [
  #       (lib.getExe' pkgs.pantalaimon-headless "pantalaimon") "-c" "${config}"
  #     ];
  #     RunAtLoad = true;
  #   };
  # };

  programs.fish = {
    interactiveShellInit = lib.mkAfter ''
      functions --copy fish_prompt vterm_old_fish_prompt
      function fish_prompt --description 'Write out the prompt; do not replace this. Instead, put this at end of your file.'
          # Remove the trailing newline from the original prompt. This is done
          # using the string builtin from fish, but to make sure any escape codes
          # are correctly interpreted, use %b for printf.
          printf "%b" (string join "\n" (vterm_old_fish_prompt))
          vterm_prompt_end
      end

      if begin; [ -n "$INSIDE_EMACS" ]; end
         fish_default_key_bindings
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
      vterm_printf = ''
        if begin; [ -n "$TMUX" ]; and string match -q -r "screen|tmux" "$TERM"; end
            # tell tmux to pass the escape sequences through
            printf "\ePtmux;\e\e]%s\007\e\\" "$argv"
        else if string match -q -- "screen*" "$TERM"
            # GNU screen (screen, screen-256color, screen-256color-bce)
            printf "\eP\e]%s\007\e\\" "$argv"
        else
            printf "\e]%s\e\\" "$argv"
        end
      '';
      vterm_cmd =  {
        description = "Run an Emacs command among the ones been defined in vterm-eval-cmds.";
        body = ''
          set -l vterm_elisp ()
          for arg in $argv
              set -a vterm_elisp (printf '"%s" ' (string replace -a -r -- '([\\\\"])' '\\\\\\\\$1' $arg))
          end
          vterm_printf '51;E'(string join ''' $vterm_elisp)
        '';
      };
      vterm_find_file = ''
        set -q argv[1]; or set argv[1] "."
        for arg in $argv
            vterm_cmd find-file (realpath "$arg")
        end
      '';
      man = ''
        if begin; [ -n "$INSIDE_EMACS" ]; end
            vterm_cmd man (string join " " -- "-l" (command man -w "$argv" 2>/dev/null))
        else
            command man "$argv"
        end
      '';
      vterm_prompt_end = ''
        vterm_printf '51;A'(whoami)'@'(hostname)':'(pwd)
      '';
    };
  };
}
