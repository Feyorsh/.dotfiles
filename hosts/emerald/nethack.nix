{ pkgs, ... }:
let
  inherit (pkgs.emacsPackages) nethack-el;
  nethack-emacs = pkgs.nethack.overrideAttrs(prev: {
    patches = (prev.patches or []) ++ [ "${nethack-el.src}/enh-${builtins.replaceStrings ["."] [""] prev.version}.patch" ];
    # postPatch = (prev.postPatch or "") + ''
    #   sed \
    #     -e 's,^CFLAGS=-g,CFLAGS=,' \
    #     -e '/^CFLAGS+=-g/d' \
    #     -e 's,/bin/gzip,${pkgs.gzip}/bin/gzip,g' \
    #     -e 's,^WINTTYLIB=.*,WINTTYLIB=-lncurses,' \
    #     -e 's,^GAMEPERM = 04755,GAMEPERM = 0755,' \
    #     -i sys/unix/hints/lisp
    # '';

    # configurePhase = ''
    #   pushd sys/unix
    #   sh setup.sh hints/lisp
    #   popd
    # '';
  });
  pkgs' = pkgs.extend { nethack = nethack-emacs; };
in
{
  imports = [
    ./dgamelaunch/module.nix pkgs'
  ];

  services.dgamelaunch = {
    enable = true;
    package = (pkgs.callPackage ./dgamelaunch/default.nix {}).overrideAttrs (prev: {
      patches = (prev.patches or []) ++ [
        ./dgamelaunch/0001-nethack-el-patch.patch
        ./dgamelaunch/0001-fixup.patch
      ];
    });
    enableSSH = true;
    telnetPort = 23;
  };
}
