{
  imports = [
    ./shell
    ./tmux.nix
    ./emulator/alacritty.nix
  ];

  home.file.".hushlogin".text = "";

  programs.bat = {
    enable = true;
    config = {
      theme = "base16";
      pager = "less -FR";
      italic-text = "always";
    };
  };
}
