{ pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-nightly-bin;
    nativeMessagingHosts = [ pkgs.tridactyl-native ];
  };

  xdg.configFile."tridactyl/tridactylrc".source = ./tridactylrc;
}
