{ pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    package = pkgs.symlinkJoin {
      name = "firefox";
      paths = [ pkgs.firefox-nightly-bin ];
      postBuild = ''
        mkdir -p $out/bin
        ln -s $out/Applications/Firefox*.app/Contents/MacOS/firefox $out/bin/
      '';
    };
    nativeMessagingHosts = [ pkgs.tridactyl-native ];
  };

  xdg.configFile."tridactyl/tridactylrc".source = ./tridactylrc;
}
