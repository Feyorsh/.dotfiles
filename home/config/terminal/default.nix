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
