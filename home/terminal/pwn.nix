{ inputs, pkgs, lib, ... }:
let
  gdb' = (pkgs.gdb.override { enableDebuginfod = false; }).overrideAttrs (p: {
    buildInputs = (p.buildInputs or []) ++ [
      inputs.debuginfod-zig.packages.${pkgs.stdenv.hostPlatform.system}.static
    ];
    configureFlags = (p.configureFlags or []) ++ [
      (lib.withFeature true "debuginfod")
    ];
  });
in
{
  home.packages = with pkgs; [
    gdb'
    pwntools
  ];

  home.file.".gdbinit".text = ''
    set history save on
    set history filename ~/.gdb_history
    set history size unlimited
    set history remove-duplicates 10

    set auto-load safe-path .

    set pagination off

    if $_regex($_gdb_setting_str("prompt"), ".*pwndbg.*")
        set show-tips off
    end
  '';

  xdg.configFile."pwn.conf".source = (pkgs.formats.ini {}).generate "pwn.conf" {
    update = {
      interval = "never";
    };
  };

  home.sessionVariables.DEBUGINFOD_URLS = "https://debuginfod.elfutils.org/";
}
