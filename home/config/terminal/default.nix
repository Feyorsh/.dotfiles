{
  imports = [
    ./shell
    ./tmux.nix
    ./emulator/alacritty.nix
  ];

  home.file.".hushlogin".text = "";
}
