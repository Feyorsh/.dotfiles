{ inputs, config, lib, pkgs, username, bootstrap, ... }:
{
  imports = with inputs; [
    spicetify-nix.homeManagerModules.default
    inputs.nixcord.homeModules.nixcord

    ./git
    ./games
    ./editor
    ./terminal
    ./finance
    ./firefox
    ./nix.nix
    ./backups.nix
    ./ai
    ./wm.nix
    ./xenu
    ./ssh.nix
  ];

  home = {
    inherit username;
    homeDirectory = "/Users/${username}";

    packages = with pkgs; [
      gimp2
      inkscape
      imagemagick
      ffmpeg

      (python314.withPackages(ps: with ps; [ ipython requests numpy matplotlib pwntools ]))
      uv
      cargo

      hyperfine

      monitorcontrol

      bitwarden-desktop

      openconnect

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

      zotero

      adwaita-icon-theme
    ] ++ lib.optionals (!bootstrap) [
      (runCommandLocal "xcode" {} ''
         mkdir -p $out/Applications/Xcode.app
         ln -s ${pkgs.darwin.xcode_26_5_Apple_silicon}/* $out/Applications/Xcode.app/
       '')
    ];

    stateVersion = "23.05";
  };
  programs.home-manager.enable = true;

  home.preferXdgDirectories = true;
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

  programs.nixcord = {
    enable = true;
    silenceNoModClientWarning = true;
  };

  launchd.agents = {
    monitorcontrol = {
      enable = true;
      config = {
        Program = "${pkgs.monitorcontrol}/Applications/MonitorControl.app/Contents/MacOS/MonitorControl";
        RunAtLoad = true;
      };
    };
    scirate-to-rss = {
      enable = true;
      config = let
        feed-generator = with pkgs.python3Packages; buildPythonApplication {
          pname = "scirate-atom-generator";
          version = "0.0.1";
          pyproject = true;
          src = pkgs.fetchgit {
            url = "https://gist.github.com/Feyorsh/641601ee9ca9769afd63fc3b0e413899";
            rev = "a19afbb5ba5bb98d750cae01062b37dfc09b9fc7";
            hash = "sha256-7ripZtAv6xOzLT9X5fmXFGK959txkw/ZQfkqevDvfcU=";
          };
          build-system = [
            setuptools
          ];
          dependencies = [
            beautifulsoup4
            requests
          ];
          meta = {
            description = "Scraper to convert personalized SciRate home page to an Atom feed";
            license = lib.licenses.wtfpl;
            mainProgram = "scirate-feed";
          };
        };
      in {
        ProgramArguments = [
          "${lib.getExe pkgs.bash}"
          "-c"
          "mkdir -p /tmp/scirate-feed; ${lib.getExe feed-generator} > /tmp/scirate-feed/feed.xml 2>/tmp/scirate-feed/err.log"
        ];
        EnvironmentVariables = {
          "XDG_CONFIG_HOME" = "/tmp";
        };
        StartCalendarInterval = [{
          Hour = 9;
          Minute = 0;
        }];
      };
    };
    elfeed-offline = {
      enable = true;
      config = {
        ProgramArguments = [
          "${lib.getExe' inputs.elfeed-offline.packages.${pkgs.stdenv.hostPlatform.system}.default "elfeed-offline"}"
          "--no-auth"
          "--cert" "/Users/${config.home.username}/.elfeed/ssl/server.pem"
          "--key" "/Users/${config.home.username}/.elfeed/ssl/server.key"
        ];
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
