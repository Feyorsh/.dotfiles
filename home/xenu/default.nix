{ pkgs, lib, config, bootstrap, ... }:
let
  xenu = pkgs.writeShellApplication {
    name = "xenu";
    text = builtins.readFile (pkgs.replaceVars ./xenu.sh {
      cores = 8;
      memory = 1024 * 16; # 16 GiB
      diskSize = 1000 * 800; # 800 GB
      sharedDir = "${config.home.homeDirectory}/Personal";
    });
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
