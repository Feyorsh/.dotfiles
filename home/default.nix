{ inputs, config, lib, pkgs, user, ... }: let
  aspell = with pkgs; (aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]));
in {
  imports = with inputs; [
    spicetify-nix.homeManagerModules.default
    mac-app-util.homeManagerModules.default

    ./config/git
    ./config/git/jujutsu.nix
    ./config/games
    ./config/editor
    ./config/terminal
    ./config/finance

    ./config/browser
  ];

  home = {
    username = "ghuebner";
    homeDirectory = "/Users/ghuebner";

    packages = with pkgs; [
      gimp

      (python312.withPackages(ps: with ps; [ ipython requests numpy ]))

      alt-tab-macos
      monitorcontrol
      time-out-macos
      keycastr


      (runCommandLocal "xcode" {} ''
         mkdir -p $out/Applications/Xcode.app
         ln -s ${pkgs.darwin.xcode_16_1}/* $out/Applications/Xcode.app/
       '')

      texlive.combined.scheme-medium
    ];

    stateVersion = "23.05";
  };
  programs.home-manager.enable = true;

  xdg.enable = true;

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

  launchd.agents = {
    time-out = {
      enable = true;
      config = {
        Program = "${pkgs.time-out-macos}/Applications/Time Out.app/Contents/MacOS/Time Out";
        RunAtLoad = true;
      };
    };
    monitorcontrol = {
      enable = true;
      config = {
        Program = "${pkgs.monitorcontrol}/Applications/MonitorControl.app/Contents/MacOS/MonitorControl";
        RunAtLoad = true;
      };
    };
  };

  programs.gpg = {
    enable = true;
    mutableKeys = true;
    mutableTrust = true;
  };
}
