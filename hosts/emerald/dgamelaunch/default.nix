{
  stdenv,
  lib,
  fetchFromGitHub,
  ncurses5,
  bison,
  flex,
  sqlite,
  libxcrypt,
  autoreconfHook,
}:
stdenv.mkDerivation {
  pname = "dgamelaunch";
  version = "1.5.1-unstable-2019-05-11";

  src = fetchFromGitHub {
    owner = "Feyorsh";
    repo = "dgamelaunch";
    rev = "master";
    hash = "sha256-EAZXI0vU0in96YH6h8izfR3UTnMpFdWKcY1fAult6S4=";
  };

  postPatch = ''
    substituteInPlace config.l --replace-fail '%{' '%option noyywrap${"\n"}%{'
  '' + lib.optionalString (stdenv.hostPlatform.isDarwin) ''
    substituteInPlace Makefile.in --replace-fail 'strlcpy.c strlcat.c' ""
    substituteInPlace dgamelaunch.c --replace-fail '#include <termios.h>' '#include <termios.h>${"\n"}#include <stddef.h>${"\n"}#include <util.h>'
    substituteInPlace dgamelaunch.h \
      --replace-fail 'extern size_t strlcpy (char *dst, const char *src, size_t siz);' "" \
      --replace-fail 'extern size_t strlcat (char *dst, const char *src, size_t siz);' ""
    substituteInPlace virus.c \
      --replace-fail '#include "strlcat.c"' "" \
      --replace-fail '#include "strlcpy.c"' ""
  '';

  nativeBuildInputs = [
    autoreconfHook
    bison
    flex
  ];

  buildInputs = [
    ncurses5
    sqlite
  ] ++ lib.optionals (stdenv.hostPlatform.isLinux) [
    libxcrypt
  ];

  configureScript = "./autogen.sh";
  configureFlags = [
    (lib.enableFeature true "debugfile")
    (lib.enableFeature true "sqlite")
    (lib.enableFeature true "shmem")
    (lib.withFeatureAs true "config-file" "dgamelaunch.conf")
  ];

  env.NIX_CFLAGS_COMPILE = "-DNOSTREAMS";

  postInstall = ''
    install -Dm 555 ee -t $out/bin/
    install -Dm 555 virus -t $out/bin/

    mkdir -p $out/share/examples
    install -Dm 555 examples/{dgamelaunch.conf,dgl_menu_*.txt,dgl-banner} $out/share/examples/
    install -Dm 555 dgl-default-rcfile $out/share/examples/
  '';

  meta = with lib; {
    description = "Server for NetHack and other games";
    homepage = "https://github.com/paxed/dgamelaunch";
    license = licenses.gpl2;
    platforms = platforms.unix;
    mainProgram = "dgamelaunch";
  };
}
