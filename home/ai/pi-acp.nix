{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:
buildNpmPackage (finalAttrs: {
  pname = "pi-acp";
  version = "0.0.26";

  src = fetchFromGitHub {
    owner = "svkozak";
    repo = "pi-acp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-F5uwgWbUmbPcJIk6ylNtxNpKpKI+hFSUWxQ7ffrdUWM=";
  };

  npmDepsHash = "sha256-vjz+jvHOq/OdT0MSwha5cbAbRXU2jex6ekfOvKnwZsk=";

  doCheck = true;

  meta = {
    description = "ACP adapter for pi-coding-agent";
    homepage = "https://github.com/svkozak/pi-acp";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "pi-acp";
  };
})
