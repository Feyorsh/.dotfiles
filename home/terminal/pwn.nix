{ pkgs, ... }:

{
  home.packages = with pkgs; [
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

  # for usage with debuginfod-zig
  home.sessionVariables.DEBUGINFOD_URLS = "https://debuginfod.elfutils.org/";
}
