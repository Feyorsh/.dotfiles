{ pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    nativeMessagingHosts = [ pkgs.tridactyl-native ];
  };

  xdg.configFile."tridactyl/tridactylrc".source = ./tridactylrc;
}
