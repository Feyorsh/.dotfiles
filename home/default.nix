{ inputs, config, lib, pkgs, user, ... }: let
  aspell = with pkgs; (aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]));
in {
  imports = with inputs; [
    spicetify-nix.homeManagerModules.default
    mac-app-util.homeManagerModules.default

    ./config/git
    ./config/games
    ./config/editor
    ./config/terminal
  ];

  home = {
    username = "ghuebner";
    homeDirectory = "/Users/ghuebner";

    packages = with pkgs; [
      gimp
      
      python312
      alt-tab-macos
      monitorcontrol
      time-out-macos

      # (writeScript "hydrate" ''
      #    #!${pkgs.python3}/bin/python3

      #    import sys
      #    import itertools
      #  '')
    ];

    stateVersion = "23.05";
  };
  programs.home-manager.enable = true;

  # TODO: add custom git command
  # git add --intent-to-add extra/flake.nix
  # git update-index --skip-worktree extra/flake.nix

  fonts.fontconfig.enable = true;

  programs.spicetify = let
    spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
  in {
    enable = true;
    enabledExtensions = with spicePkgs.extensions; [
      playNext
      volumePercentage
    ];
    theme = spicePkgs.themes.text;
    colorScheme = "RosePineMoon";
  };

 programs.gpg = {
   enable = true;
   mutableKeys = true;
   mutableTrust = true;
 };
 # services.gpg-agent = {
 #   enable = true;
 #   defaultCacheTtl = 1200;
 #   maxCacheTtl = 86400;
 #   pinentryFlavor = null;
 #   extraConfig = ''
 #     pinentry-program '' +
 #   pkgs.writeShellScript "custom-pinentry" ''
 #     case $PINENTRY_USER_DATA in
 #     emacs)
 #         exec ${pkgs.pinentry.emacs}/bin/pinentry "$@"
 #         ;;
 #     gtk)
 #         exec ${pkgs.pinentry.gtk2}/bin/pinentry "$@"
 #         ;;
 #     *)
 #         exec ${pkgs.pinentry.tty}/bin/pinentry "$@"
 #     esac
 #   '' + ''

 #     allow-emacs-pinentry
 #     allow-loopback-pinentry
 #   '';
 # };
}
