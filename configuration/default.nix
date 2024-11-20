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
            diskSize = 30 * 1024;
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

  security.chmodbpf = {
    enable = true;
    members = [ username ];
  };

  services.xquartz.enable = true;

  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;


  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;
  time.timeZone = "America/Chicago";
  system.defaults.screencapture.location = "${home}/Images/Screenshots";
  system.defaults.menuExtraClock.Show24Hour = true;
  system.defaults.loginwindow.GuestEnabled = false;
  system.defaults.finder.CreateDesktop = true;
  system.defaults.finder.AppleShowAllFiles = true;
  system.defaults.finder.AppleShowAllExtensions = true;
  system.defaults.finder.FXPreferredViewStyle = "icnv";
  system.defaults.dock.tilesize = 64;
  system.defaults.dock.show-recents = false;
  system.defaults.dock.mru-spaces = false;
  system.defaults.dock.minimize-to-application = true;
  system.defaults.dock.mineffect = "scale";
  system.defaults.dock.launchanim = false;
  system.defaults.WindowManager.EnableStandardClickToShowDesktop = false;
  system.defaults.NSGlobalDomain.AppleShowScrollBars = "WhenScrolling";

  system.defaults.alf.stealthenabled = 1;
  system.defaults.SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
  system.defaults.NSGlobalDomain.NSDocumentSaveNewDocumentsToCloud = false;

  system.defaults.NSGlobalDomain.InitialKeyRepeat = 20;
  system.defaults.NSGlobalDomain.KeyRepeat = 2;

  system.defaults.NSGlobalDomain.AppleShowAllFiles = true;
  system.defaults.NSGlobalDomain.AppleScrollerPagingBehavior = true;
  system.defaults.NSGlobalDomain.AppleInterfaceStyle = "Dark";
  system.defaults.NSGlobalDomain.AppleICUForce24HourTime = true;

  system.defaults.dock.autohide = true;
  system.defaults.dock.autohide-delay = 0.0;
  system.defaults.dock.autohide-time-modifier = 0.3;
  # system.defaults.dock.mru-spaces

  # TODO ubersicht: music

  security.pam.enableSudoTouchIdAuth = true;

  system.defaults.CustomUserPreferences = {
	  "com.apple.desktopservices" = {
		  # Avoid creating .DS_Store files on external drives
		  DSDontWriteNetworkStores = true;
		  DSDontWriteUSBStores = true;
	  };
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
        "4096"
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
