{
  lib,
  trivialBuild,
  fetchFromGitHub,
  gzip,
  nethack,
}:

trivialBuild (finalAttrs:
let
  nethack-emacs = nethack.overrideAttrs(prev: {
    patches = [ "${finalAttrs.src}/enh-${builtins.replaceStrings ["."] [""] prev.version}.patch" ];
    postPatch = (prev.postPatch or "") + ''
      sed \
        -e 's,^CFLAGS=-g,CFLAGS=,' \
        -e '/^CFLAGS+=-g/d' \
        -e 's,/bin/gzip,${gzip}/bin/gzip,g' \
        -e 's,^WINTTYLIB=.*,WINTTYLIB=-lncurses,' \
        -e 's,^GAMEPERM = 04755,GAMEPERM = 0755,' \
        -i sys/unix/hints/linux-lisp
    '';

    configurePhase = ''
      pushd sys/unix
      sh setup.sh hints/linux-lisp
      popd
    '';
  });
in {
  pname = "nethack-el";
  version = "0.13.3-pre";

  src = fetchFromGitHub {
    owner = "Feyorsh";
    repo = "nethack-el";
    rev = "b49d56461505bcedd4b321fb01710f7206e7f315";
    hash = "sha256-HeEMIpZJULKZ39NV/zprejloDfXXfI0XXupFYIDYNe8=";
  };

  postInstall = ''
    mkdir -p $LISPDIR/build
    cp ${nethack-emacs}/bin/nethack $LISPDIR/build/
  '';

  passthru.nethack = nethack-emacs;

  meta = {
    homepage = "https://github.com/be11ng/nethack-el";
    description = "Emacs interface to the roguelike NetHack";
    license = with lib.licenses; [ gpl2 bsd3 nethack-emacs.meta.license ];
  };
})
