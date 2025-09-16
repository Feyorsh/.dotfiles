{ config, pkgs, lib, inputs, username, ... }:
let
  home = config.users.users.${username}.home;
in
{
  imports = [
    ./yabai
    ./dictd.nix
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
    xz
    unixtools.wall
    unixtools.watch
    iproute2mac

    vim
    wget
    curl
    socat
    ripgrep
    fd
    jq
  ];

  fonts = {
    packages = with pkgs; [
      source-sans-pro
      source-serif-pro
      sarasa-gothic
      libertinus
      etBook
      atkinson-hyperlegible
      gentium-book

      jetbrains-mono
      julia-mono

      twemoji-color-font
      emacs-all-the-icons-fonts
    ];
  };

  nix = {
    enable = true;
    package = pkgs.nixVersions.latest;

    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };

    optimise.automatic = true;

    settings = {
      keep-outputs = true;
      keep-derivations = true;

      experimental-features = "nix-command flakes";

      # more like pwn-me-mommy
      accept-flake-config = true;
      trusted-users = [ "root" "@admin" ];

      sandbox = true;

      fallback = true;
      warn-dirty = false;
    };

    # buildMachines = [{
    #   hostName = "Vermillion";
    #   protocol = "ssh-ng";
    #   speedFactor = 3;
    #   sshUser = "nixremote";
    #   sshKey = "/var/root/.ssh/nixremote";
    #   supportedFeatures = [
    #     "kvm"
    #     "big-parallel"
    #   ];
    #   systems = [
    #     "x86_64-linux"
    #     "aarch64-linux"
    #   ];
    # }];
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

   channel.enable = false;
   nixPath = [
     "nixpkgs=flake:nixpkgs"
     "darwin=flake:darwin"
     "home-manager=flake:home-manager"
   ];

    registry = {
      darwin.to = {
        type = "path";
        path = inputs.darwin.outPath;
      };
      home-manager.to = {
        type = "path";
        path = inputs.home-manager.outPath;
      };
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
  system.primaryUser = username;
  programs.fish.enable = true;
  programs.zsh.enable = true;

  networking.hostName = "Opal";
  networking.computerName = "Opal";
  networking.applicationFirewall.enableStealthMode = true;

  time.timeZone = "America/Chicago";

  security.chmodbpf = {
    enable = true;
    members = [ username ];
  };
  security.pam.services.sudo_local.touchIdAuth = true;

  services.xquartz.enable = true;

  programs.ccache = {
    enable = true;
    packageNames = [
      "emacs30-macport"
      "llvm"
    ];
  };

  services.tailscale = {
    enable = true;
    package = pkgs.tailscale.overrideAttrs (prev: {
      # use builtin ifconfig (BSD) instead of inetutils ifconfig
      postPatch = (prev.postPatch or "") + ''
        sed -e 's,"ifconfig","/sbin/ifconfig",' \
            -i wgengine/router/router_userspace_bsd.go
      '';
      doCheck = false;
    });
  };

  services.dictd.enable = true;

  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;


  system = {
    # misc aesthetics
    startup.chime = false;
    defaults.screencapture.location = "${home}/Images/Screenshots";
    defaults.screencapture.target = "clipboard";
    defaults.NSGlobalDomain.AppleInterfaceStyle = "Dark";
    defaults.menuExtraClock.Show24Hour = true;
    defaults.NSGlobalDomain.AppleICUForce24HourTime = true;
    defaults.NSGlobalDomain.NSTextShowsControlCharacters = true;

    # finder/files
    defaults.finder.CreateDesktop = true;
    defaults.finder.AppleShowAllFiles = true;
    defaults.finder.AppleShowAllExtensions = true;
    defaults.finder.FXPreferredViewStyle = "icnv";
    defaults.finder._FXShowPosixPathInTitle = true;
    defaults.finder.ShowExternalHardDrivesOnDesktop = false;
    defaults.finder.ShowRemovableMediaOnDesktop = false;
    defaults.finder.NewWindowTarget = "Other";
    defaults.finder.NewWindowTargetPath = "file://${home}/Downloads";
    defaults.CustomUserPreferences = {
      "com.apple.desktopservices" = {
        # Avoid creating .DS_Store files on external drives
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
      "com.apple.Safari" = {
        "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" = true;
        HomePage = "about:blank";
      };
      "com.apple.DiskUtility" = {
        advanced-image-options = true;
      };
      "com.apple.ActivityMonitor" = {
        UpdatePeriod = 2;
        IconType = 2; # show network usage
      };
    };
    defaults.NSGlobalDomain.NSDocumentSaveNewDocumentsToCloud = false;
    defaults.NSGlobalDomain.NSNavPanelExpandedStateForSaveMode = true;
    defaults.NSGlobalDomain.NSNavPanelExpandedStateForSaveMode2 = true;
    defaults.NSGlobalDomain.AppleShowAllFiles = true;
    defaults.NSGlobalDomain."com.apple.springing.delay" = 0.2;

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
    defaults.dock.wvous-br-corner = 1; # disabled
    defaults.universalaccess.reduceMotion = true;
    defaults.WindowManager.EnableStandardClickToShowDesktop = false;
    defaults.NSGlobalDomain.AppleShowScrollBars = "WhenScrolling";
    defaults.NSGlobalDomain.AppleScrollerPagingBehavior = true;

    # system/security
    defaults.SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
    defaults.loginwindow.GuestEnabled = false;

    # keyboard
    keyboard.enableKeyMapping = true;
    keyboard.remapCapsLockToControl = true;
    defaults.NSGlobalDomain.InitialKeyRepeat = 20;
    defaults.NSGlobalDomain.KeyRepeat = 2;
    defaults.NSGlobalDomain."com.apple.trackpad.forceClick" = true;
    defaults.hitoolbox.AppleFnUsageType = "Change Input Source";
  };


  system.activationScripts.activateConfig.text = ''
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
        text = builtins.readFile ./beorg-sync.sh;
      });
      StartInterval = 2 * 60;
      StandardOutPath = "/tmp/beorg_sync.out.log";
      StandardErrorPath = "/tmp/beorg_sync.err.log";
    };
  };

  ids.gids.nixbld = 350;
  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}
