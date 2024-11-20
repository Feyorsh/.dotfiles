{ config, pkgs, lib, inputs, username, ... }:
let
  home = config.users.users.${username}.home;
in
{
  imports = [
    ./yabai
  ];

  # essential packages; my perl-less swiss army chainsaw
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

    #samba # TODO: move to the 391 flake and just do ugly impure stuff there
    # https://apple.stackexchange.com/questions/445372/samba-dot-org-smbd-does-not-start-on-macos-monterey-12-5

    # I think this is useful if only to tell xcode cli to shut the fuck up
    pkgs.darwin.xcode_15_1
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
    # https://github.com/NixOS/nix/issues/7273
    # settings.auto-optimise-store = true;
    settings = {
      auto-optimise-store = false;
      keep-outputs = true;
      experimental-features = "nix-command flakes";
      # feeling a little sus after that maplectf chal...
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
		  # Avoid creating .DS_Store files
		  DSDontWriteNetworkStores = true;
		  DSDontWriteUSBStores = true;
	  };
    # this also doesn't work. meh.
	  "com.apple.Accessibility" = {
		  ReduceMotionEnabled = 1;
	  };

    # this doesn't work. this allows Console.app to actually... work
    # also requires disabling SIP
    #	"com.apple.system.logging" = {
    #		System = { Enable-Private-Data = true; }
    #};
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
    # how to make a "memory leak" for your harddrive ;)
    # "enableCoredump".serviceConfig = {
    #   ProgramArguments = [
    #     "/bin/launchctl"
    #     "limit"
    #     "core"
    #     "4611686018427387904"
    #     "4611686018427387904"
    #   ];
    #   RunAtLoad = true;
    # };
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

	# FUCK SAMBA FUCK THIS BULLSHIT


  # system.activationScripts.samba_lock.text = lib.stringAfter [ "var" ] ''
    # mkdir -p /var/lock/samba
    # mkdir -p /var/cache/samba
    # mkdir -p /var/cache/samba
  # '';
# 
# 
  # environment.etc."samba/smb.conf".text = ''
    # [global]
        # security = user
        # passdb backend = tdbsam:/etc/samba/private/passdb.tdb
        # browseable = yes
        # log file = /var/log/samba/log.%m
        # writeable = yes
        # min protocol = NT1
        # hosts allow = ;	
        # ntlm auth = yes
        # lanman auth = no
        # client lanman auth = no
    # [ece391_share]
        # comment = ECE391Shared
        # path = /Users/ghuebner/School/ECE391/share/
        # valid users = ghuebner
        # browseable = yes
        # writable = yes
        # guest ok = yes
  # '';
# 
# 
  # environment.launchDaemons."org.samba.nmbd.plist".text = ''
    # <?xml version="1.0" encoding="UTF-8"?>
    # <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    # <plist version="1.0">
    # <dict>
    # <key>Label</key>
    # <string>org.samba.nmbd</string>
    # <key>OnDemand</key>
    # <false/>
    # <key>ProgramArguments</key>
    # <array>
    # <string>${pkgs.samba.outPath}/sbin/nmbd</string>
    # <string>-D</string>
    # </array>
    # <key>RunAtLoad</key>
    # <true/>
    # <key>WorkingDirectory</key>
    # <string>/var/lock/samba</string>
    # <key>ServiceDescription</key>
    # <string>netbios</string>
    # </dict>
    # </plist>
  # '';
# 
  # environment.launchDaemons."org.samba.smbd.plist".text = ''
    # <?xml version="1.0" encoding="UTF-8"?>
    # <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    # <plist version="1.0">
    # <dict>
    # <key>Label</key>
    # <string>org.samba.smbd</string>
    # <key>OnDemand</key>
    # <false/>
    # <key>ProgramArguments</key>
    # <array>
    # <string>${pkgs.samba.outPath}/sbin/smbd</string>
    # <string>-D</string>
    # </array>
    # <key>RunAtLoad</key>
    # <true/>
    # <key>ServiceDescription</key>
    # <string>netbios</string>
    # </dict>
    # </plist>
# '';


  # end samba bullshit

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}
