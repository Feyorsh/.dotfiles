{ inputs, pkgs, ... }:
let
  nurPkgs = import inputs.nur {
    inherit pkgs;
    nurpkgs = pkgs;
  };
  extensions = with nurPkgs.repos.rycee.firefox-addons; [
    ublock-origin
    tridactyl
    kagi-search
    kagi-translate
    web-archives
    bitwarden
  ];
in
{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    nativeMessagingHosts = [ pkgs.tridactyl-native ];
    profiles."Personal" = {
      id = 0;
      extensions.packages = extensions;
    };
    profiles."School" = {
      id = 1;
      extensions.packages = extensions;
    };
  };

  xdg.configFile."tridactyl/tridactylrc".source = ./tridactylrc;
}
