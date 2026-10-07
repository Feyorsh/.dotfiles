{ lib, config, username, host, ... }:
let
  home = config.users.users.${username}.home;
in
{
  imports = [
    ./swiss-army.nix
    ./xcode-shims.nix
    ./nix.nix
  ];

  networking.hostName = host;
  networking.localHostName = host;
  networking.computerName = lib.toSentenceCase host;

  networking.dns = [ "192.168.1.1" ];

  time.timeZone = lib.mkDefault "America/Chicago";

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
      "com.apple.AppleMultitouchTrackpad" = {
        TrackpadThreeFingerHorizSwipeGesture = 0;
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

  networking.applicationFirewall.enableStealthMode = true;
}
