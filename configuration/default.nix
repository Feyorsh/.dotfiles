{ config, pkgs, lib, inputs, username, ... }:
let
  home = config.users.users.${username}.home;
in
{
  imports = [
    ./yabai
  ];

  # essential packages; my perl-less swiss army chainsaw
  # some of these are shadowed by per-user packages, these are meant to be user- and machine-agnostic
  environment.systemPackages = with pkgs; [
    coreutils
    findutils
    diffutils
    inetutils
    gawk
    gnused
    gnugrep
    gnutar
    gzip
    unixtools.wall
    unixtools.watch

    vim
    wget
    curl
    ripgrep
    fd
  ];
  environment.variables = { EDITOR = "vim"; };

  fonts = {
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
      source-sans-pro
      source-serif-pro
      sarasa-gothic # TODO: override to select fonts like nerdfonts, cause this boi is BIG
      libertine
      jetbrains-mono
      twemoji-color-font
      emacs-all-the-icons-fonts
    ];
  };

  services.nix-daemon.enable = true;
  nix = {
    package = pkgs.nixVersions.nix_2_20;
    # https://github.com/NixOS/nix/issues/7273
    # settings.auto-optimise-store = true;
    settings = {
      auto-optimise-store = false;
      keep-outputs = true;
      experimental-features = "nix-command flakes";
      # more like pwn-me-mommy
      accept-flake-config = true;
      trusted-users = [ "root" "@admin" ];
      sandbox = true;
    };
    linux-builder = {
      enable = true;
      config = {
        virtualisation = {
          darwin-builder = {
            diskSize = 40 * 1024;
          };
        };
      };
    };

    registry = {
      templates = {
        from = {
          id = "templates";
          type = "indirect";
        };
        to = {
          type = "path";
          path = "${home}/.dotfiles/templates";
        };
      };
      fyshpkgs = {
        from = {
          id = "fyshpkgs";
          type = "indirect";
        };
        to = {
          type = "git";
          ref = "main";
          url = "file://${home}/Personal/fyshpkgs";
        };
      };
    };
  };

  users.knownUsers = [ username ];
  users.users.${username} = {
    name = username;
    uid = 501;
    home = "/Users/${username}";
    shell = pkgs.fish;
  };
  programs.fish.enable = true;
  programs.zsh.enable = true;

  networking.localHostName = "Aqua";
  networking.computerName = "Aqua";
  time.timeZone = "America/Chicago";

  security.chmodbpf = {
    enable = true;
    members = [ username ];
  };
  security.pam.enableSudoTouchIdAuth = true;

  services.xquartz.enable = true;

  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;


  system = {
    # misc aesthetics
    startup.chime = false;
    defaults.screencapture.location = "${home}/Images/Screenshots";
    defaults.NSGlobalDomain.AppleInterfaceStyle = "Dark";
    defaults.menuExtraClock.Show24Hour = true;
    defaults.NSGlobalDomain.AppleICUForce24HourTime = true;

    # finder/files
    defaults.finder.CreateDesktop = true;
    defaults.finder.AppleShowAllFiles = true;
    defaults.finder.AppleShowAllExtensions = true;
    defaults.finder.FXPreferredViewStyle = "icnv";
    defaults.finder._FXShowPosixPathInTitle = true;
    defaults.CustomUserPreferences = {
      "com.apple.desktopservices" = {
        # Avoid creating .DS_Store files on external drives
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
    };
    defaults.NSGlobalDomain.NSDocumentSaveNewDocumentsToCloud = false;
    defaults.NSGlobalDomain.AppleShowAllFiles = true;

    # dock
    defaults.dock.autohide = true;
    defaults.dock.autohide-delay = 0.0;
    defaults.dock.autohide-time-modifier = 0.3;
    defaults.dock.tilesize = 64;
    defaults.dock.show-recents = false;
    defaults.dock.mru-spaces = false;
    defaults.dock.minimize-to-application = true;
    defaults.dock.mineffect = "scale";
    defaults.dock.launchanim = false;
    defaults.universalaccess.reduceMotion = true;
    defaults.WindowManager.EnableStandardClickToShowDesktop = false;
    defaults.NSGlobalDomain.AppleShowScrollBars = "WhenScrolling";
    defaults.NSGlobalDomain.AppleScrollerPagingBehavior = true;

    # system/security
    defaults.SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
    defaults.alf.stealthenabled = 1;
    defaults.loginwindow.GuestEnabled = false;

    # keyboard
    keyboard.enableKeyMapping = true;
    keyboard.remapCapsLockToControl = true;
    defaults.NSGlobalDomain.InitialKeyRepeat = 20;
    defaults.NSGlobalDomain.KeyRepeat = 2;
    defaults.NSGlobalDomain."com.apple.trackpad.forceClick" = true;
  };


  system.activationScripts.postUserActivation.text = ''
    # Following line should allow us to avoid a logout/login cycle
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';

  launchd.daemons = {
    "fdLimitUp".serviceConfig = {
      ProgramArguments = [
        "/bin/launchctl"
        "limit"
        "maxfiles"
        "10000"
        "4611686018427387904" # can't set unlimited
      ];
      RunAtLoad = true;
    };
  };

  launchd.user.agents = {
    beorg-sync.serviceConfig = {
      Program = lib.getExe (pkgs.writeShellApplication {
        name = "beorg-sync";
        runtimeInputs = [ pkgs.coreutils ];
        text = builtins.readFile ./org-sync.sh;
      });
      StartInterval = 2 * 60;
      StandardOutPath = "/tmp/beorg_sync.out.log";
      StandardErrorPath = "/tmp/beorg_sync.err.log";
    };
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}
