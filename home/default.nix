{ inputs, config, lib, pkgs, user, ... }:
{
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
    ./config/nix.nix
    ./config/backups.nix
    ./config/ai.nix
  ];

  home = {
    username = "ghuebner";
    homeDirectory = "/Users/ghuebner";

    packages = with pkgs; [
      gimp2
      inkscape
      imagemagick

      (python314.withPackages(ps: with ps; [ ipython requests numpy pwntools ]))
      uv
      cargo

      alt-tab-macos
      monitorcontrol
      time-out-macos
      keycastr

      bitwarden-desktop

      (runCommandLocal "xcode" {} ''
         mkdir -p $out/Applications/Xcode.app
         ln -s ${pkgs.darwin.xcode_16_3}/* $out/Applications/Xcode.app/
       '')

      (texlive.combine {
        inherit (texlive) scheme-medium

          # needed for org-mode
          mylatexformat capt-of preview
          # needed for jeffe
          mdframed zref needspace arydshln
          # needed for pset class
          cancel fvextra tcolorbox pdfcol
          # fonts
          cochineal fontaxes inconsolata cabin newtx mathalpha boondox
          # misc improvements to defaults
          xstring upquote

          # misc packages I commonly use
          braket cjk embedfile nopageno;
      })
      typst

      adwaita-icon-theme
    ];

    stateVersion = "23.05";
  };
  programs.home-manager.enable = true;

  xdg.enable = true;

  fonts.fontconfig.enable = true;

  programs.spicetify = let
    spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  in {
    enable = true;
    enabledExtensions = with spicePkgs.extensions; [
      playNext
      volumePercentage
      fullAppDisplay
    ];
    alwaysEnableDevTools = true;
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
