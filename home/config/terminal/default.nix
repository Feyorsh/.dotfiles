{ pkgs, ... }:
{
  imports = [
    ./shell
    ./tmux.nix
    ./emulator/alacritty.nix
  ];

  home.file.".hushlogin".text = "";

  home.file.".gdbinit".text = ''
    set history save on
    set history filename ~/.gdb_history
    set history size unlimited
    set history remove-duplicates 10

    set pagination off

    if $_regex($_gdb_setting_str("prompt"), ".*pwndbg.*")
        set show-tips off
    done
  '';

  xdg.configFile."pwn.conf".source = (pkgs.formats.ini {}).generate "pwn.conf" {
    # context = {
    #   timeout = 10;
    # };
    update = {
      interval = "never";
    };

  };

  xdg.configFile."poke/pokerc.conf".text = ''
    .set endian little
    .set omode tree
    .set oacutoff 5
    .set pretty-print yes
    .set pager yes
  '';

  programs.bat = {
    enable = true;
    config = {
      theme = "base16";
      pager = "less -FR";
      italic-text = "always";
    };
  };
}
