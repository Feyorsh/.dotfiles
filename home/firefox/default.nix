{ inputs, pkgs, ... }:
let
  nurPkgs = import inputs.nur {
    inherit pkgs;
    nurpkgs = pkgs;
  };
  commonExtensions = with nurPkgs.repos.rycee.firefox-addons; [
    ublock-origin
    tridactyl
    kagi-search
    kagi-translate
    web-archives
    bitwarden
    dearrow
  ];
in
{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    configPath = "Library/Application Support/org.nixos.firefox";
    nativeMessagingHosts = [ pkgs.tridactyl-native ];
    profiles."Personal" = {
      id = 0;
      extensions.packages = commonExtensions ++ (with nurPkgs.repos.rycee.firefox-addons; [
        nurPkgs.repos.rycee.firefox-addons."10ten-ja-reader"
        foxyproxy-standard
        tampermonkey
      ]);
    };
    profiles."School" = {
      id = 1;
      extensions.packages = commonExtensions ++ (with nurPkgs.repos.rycee.firefox-addons; [
        zotero-connector
      ]);
    };
  };

  xdg.configFile."tridactyl/tridactylrc".source = ./tridactylrc;
}
