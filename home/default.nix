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
    ./config/finance
  ];

  home = {
    username = "ghuebner";
    homeDirectory = "/Users/ghuebner";

    packages = with pkgs; [
      gimp

      (python312.withPackages(ps: with ps; [ requests numpy ]))

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
}
