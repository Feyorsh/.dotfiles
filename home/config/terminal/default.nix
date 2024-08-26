{
  imports = [ ./shell ./emulator/alacritty.nix ];

  home.file.".hushlogin".text = "";
}
