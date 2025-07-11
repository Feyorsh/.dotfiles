{ pkgs, config, ... }:
{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-nightly-bin.overrideAttrs (_: {
      override = _: pkgs.firefox-nightly-bin;
    });
    nativeMessagingHosts = [ pkgs.tridactyl-native ];
  };

  home.packages = [
    (pkgs.symlinkJoin {
      name = "firefox";
      paths = [];
      postBuild = ''
        mkdir -p $out/bin
        ln -s ${pkgs.firefox-nightly-bin}/Applications/Firefox*.app/Contents/MacOS/firefox $out/bin/
      '';
    })
  ];

  xdg.configFile."tridactyl/tridactylrc".source = ./tridactylrc;
}
