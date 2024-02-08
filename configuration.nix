{ config, pkgs, lib, ... }: {
  environment.systemPackages = with pkgs; [
    vim
    git
    git-lfs
    wget
    jq
    ripgrep
    silver-searcher
    fd
    spotify
    wezterm

	  # wrapper is broken
    # probably a new bug, I'll bisect... eventually
    # https://github.com/NixOS/nixpkgs/commits/130e80523f73b8950568246d3b4c294825923448/pkgs/build-support/emacs/wrapper.nix
    #((emacsPackagesFor emacsMacport).emacsWithPackages (epkgs: [ epkgs.vterm epkgs.pdf-tools pkgs.mu pkgs.aspell pkgs.aspellDicts.en]))
    emacs29

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
  nix.package = pkgs.nix;
  nix.settings.auto-optimise-store = true;
  nix.settings.experimental-features = "nix-command flakes";

  nix.registry.templates = {
	  from = {
		  id = "templates";
		  type = "indirect";
	  };
	  to = {
		  path = "${config.users.users.ghuebner.home}/.dotfiles/templates";
		  type = "path";
	  };
  }
;

  users.users.ghuebner = {
    name = "ghuebner";
    home = "/Users/ghuebner";
  };
  networking.localHostName = "Aqua";
  networking.computerName = "Aqua";


  # Create /etc/zshrc that loads the darwin environment.
  programs.zsh.enable = true;  # default shell on catalina
  # programs.fish.enable = true;

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

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}
