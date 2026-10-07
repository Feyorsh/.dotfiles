{
  cores ? 4,
  memory ? 1024 * 8, # 8 GiB
  diskSize ? 1000 * 500, # 500 GB
  sharedDir ? "/var/lib/xenu",
}@args:
{ pkgs, lib, bootstrap, ... }:
let
  xenu = pkgs.writeShellApplication {
    name = "xenu";
    text = builtins.readFile (pkgs.replaceVars ./xenu.sh args);
    runtimeInputs = with pkgs; [
      coreutils
      qemu-utils
      darwin.xattr
      openssl
      gnused
      vfkit
    ];
  };
in
lib.optionalAttrs (!bootstrap) {
  home.packages = [ xenu ];

  launchd.agents.xenu = {
    enable = true;
    config = {
      Program = lib.getExe xenu;
      WorkingDirectory = "/var/lib/xenu";
      RunAtLoad = true;
    };
  };
}
