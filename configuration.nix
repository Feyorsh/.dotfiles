{ config, pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    vim
    git
    git-lfs
    wget
    jq
    ripgrep
    silver-searcher
    fd

    samba # TODO: move to the 391 flake and just do ugly impure stuff there
    # https://apple.stackexchange.com/questions/445372/samba-dot-org-smbd-does-not-start-on-macos-monterey-12-5

    # I think this is useful if only to tell xcode cli to shut the fuck up
    darwin.xcode
  ];

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
      source-sans-pro
      sarasa-gothic # TODO: override to select fonts like nerdfonts, cause this boi is BIG
      jetbrains-mono
      twitter-color-emoji
      emacs-all-the-icons-fonts
    ];
  };

  services.nix-daemon.enable = true;
  nix = {
    package = pkgs.nixVersions.master;
    # bruh what https://github.com/NixOS/nix/issues/7273
    #settings.auto-optimise-store = true;
    settings = {
      auto-optimise-store = false;
      keep-outputs = true;
      experimental-features = "nix-command flakes";
      # feeling a little sus after that maplectf chal...
      accept-flake-config = true;
    };
  #   extraOptions = ''
  #   builders = ssh-ng://builder@linux-builder aarch64-linux /etc/builder_ed25519 4 - - - c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUpCV2N4Yi9CbGFxdDFhdU90RStGOFFVV3JVb3RpQzVxQkorVXVFV2RWQ2Igcm9vdEBuaXhvcwo=
  #   # Not strictly necessary, but this will reduce your disk utilization
  #   builders-use-substitutes = true
  # '';

    registry = {
      # nixpkgs = {
      #   from = { id = "nixpkgs"; type = "indirect"; };
      #   flake = inputs.nixpkgs;
      # };
      templates = {
        from = {
          id = "templates";
          type = "indirect";
        };
        to = {
          path = "${config.users.users.ghuebner.home}/.dotfiles/templates";
          type = "path";
        };
      };
      fyshpkgs = {
        from = {
          id = "fyshpkgs";
          type = "indirect";
        };
        to = {
          path = "${config.users.users.ghuebner.home}/fyshpkgs";
          type = "path";
        };
      };
    };
  };

  users.users.ghuebner = {
    name = "ghuebner";
    home = "/Users/ghuebner";
  };
  networking.localHostName = "Aqua";
  networking.computerName = "Aqua";


  # login shell
  programs.zsh.enable = true;  # default shell on catalina

  # TODO: get self (from flake) in here
  #system.configurationRevision = self.rev or self.dirtyRev or null;


  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;
  time.timeZone = "America/Chicago";
  system.defaults.screencapture.location = "${config.users.users.ghuebner.home}/Images/Screenshots";
  system.defaults.menuExtraClock.Show24Hour = true;
  system.defaults.loginwindow.GuestEnabled = false;
  system.defaults.finder.CreateDesktop = false;
  system.defaults.finder.AppleShowAllFiles = true;
  system.defaults.finder.AppleShowAllExtensions = true;
  system.defaults.finder.FXPreferredViewStyle = "icnv";
  system.defaults.dock.tilesize = 64;
  system.defaults.dock.show-recents = false;
  system.defaults.dock.mru-spaces = false;
  system.defaults.dock.minimize-to-application = true;
  system.defaults.dock.mineffect = "scale";
  system.defaults.dock.launchanim = false;
  system.defaults.NSGlobalDomain.AppleShowScrollBars = "WhenScrolling";

  # TODO: config with yabai
  #system.defaults.dock.autohide
  #system.defaults.dock.autohide-delay
  #system.defaults.dock.autohide-time-modifier

  system.defaults.alf.stealthenabled = 1;
  system.defaults.SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
  system.defaults.NSGlobalDomain.NSDocumentSaveNewDocumentsToCloud = false;

  # TODO
  #system.defaults.NSGlobalDomain.InitialKeyRepeat
  #system.defaults.NSGlobalDomain.KeyRepeat

  system.defaults.NSGlobalDomain.AppleShowAllFiles = true;
  system.defaults.NSGlobalDomain.AppleScrollerPagingBehavior = true;
  system.defaults.NSGlobalDomain.AppleInterfaceStyle = "Dark";
  system.defaults.NSGlobalDomain.AppleICUForce24HourTime = true;

  # TODO i guess?
  # activitymonitor

  # TODO !!
  services.yabai.enable = true;
  #services.yabai.
  services.yabai.enableScriptingAddition = true;
  services.skhd.enable = true;

  # TODO spacebar status bar
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

  environment.etc."ssh/ssh_config.d/100-linux-builder.conf".text = ''
    Host linux-builder
        Hostname localhost
        HostKeyAlias linux-builder
        Port 31022
  '';


	# FUCK SAMBA FUCK THIS BULLSHIT


  system.activationScripts.samba_lock.text = lib.stringAfter [ "var" ] ''
    mkdir -p /var/lock/samba
    mkdir -p /var/cache/samba
    mkdir -p /var/cache/samba
  '';


  environment.etc."samba/smb.conf".text = ''
    [global]
        security = user
        passdb backend = tdbsam:/etc/samba/private/passdb.tdb
        browseable = yes
        log file = /var/log/samba/log.%m
        writeable = yes
        min protocol = NT1
        hosts allow = ;	
        ntlm auth = yes
        lanman auth = no
        client lanman auth = no
    [ece391_share]
        comment = ECE391Shared
        path = /Users/ghuebner/School/ECE391/share/
        valid users = ghuebner
        browseable = yes
        writable = yes
        guest ok = yes
  '';


  environment.launchDaemons."org.samba.nmbd.plist".text = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
    <key>Label</key>
    <string>org.samba.nmbd</string>
    <key>OnDemand</key>
    <false/>
    <key>ProgramArguments</key>
    <array>
    <string>${pkgs.samba.outPath}/sbin/nmbd</string>
    <string>-D</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>WorkingDirectory</key>
    <string>/var/lock/samba</string>
    <key>ServiceDescription</key>
    <string>netbios</string>
    </dict>
    </plist>
  '';

  environment.launchDaemons."org.samba.smbd.plist".text = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
    <key>Label</key>
    <string>org.samba.smbd</string>
    <key>OnDemand</key>
    <false/>
    <key>ProgramArguments</key>
    <array>
    <string>${pkgs.samba.outPath}/sbin/smbd</string>
    <string>-D</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>ServiceDescription</key>
    <string>netbios</string>
    </dict>
    </plist>
'';


  # end samba bullshit



  # I actually have no idea why I added this. stuff symlinks fine with vanilla nix-darwin
  #system.activationScripts.applications.text = lib.mkForce ''
  #    echo "setting up /Applications..." >&2
  #    applications="/Applications"
  #    nix_apps="$applications/Nix Apps"
  #
  #    # Needs to be writable by the user so that home-manager can symlink into it
  #    if ! test -d "$applications"; then
  #        mkdir -p "$applications"
  #        chown ghuebner: "$applications"
  #        chmod u+w "$applications"
  #    fi
  #
  #    # Delete the directory to remove old links
  #    rm -rf "$nix_apps"/**
  #    #mkdir -p "$nix_apps"
  #    find ${config.system.build.applications}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
  #        while read src; do
  #            # Spotlight does not recognize symlinks, it will ignore directory we link to the applications folder.
  #            # It does understand MacOS aliases though, a unique filesystem feature. Sadly they cannot be created
  #            # from bash (as far as I know), so we use the oh-so-great Apple Script instead.
  #            /usr/bin/osascript -e "
  #                set fileToAlias to POSIX file \"$src\" 
  #                set applicationsFolder to POSIX file \"$nix_apps\"
  #                tell application \"Finder\"
  #                    make alias file to fileToAlias at applicationsFolder
  #                    # This renames the alias; 'mpv.app alias' -> 'mpv.app'
  #                    set name of result to \"$(rev <<< "$src" | cut -d'/' -f1 | rev)\"
  #                end tell
  #            " 1>/dev/null
  #        done
  #  '';

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}
