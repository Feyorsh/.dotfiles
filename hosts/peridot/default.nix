{ config, pkgs, lib, inputs, username, ... }:
let
  home = config.users.users.${username}.home;
in
{
  imports = [
    ../../darwin
    ../../darwin/graphical.nix
    ../../darwin/tailscale.nix

    ./dictd.nix
    # ./restic.nix
  ];

  environment.systemPackages = with pkgs; [
    btop
    openssh # just want ssh, no sshd service
  ];

  fonts = {
    packages = with pkgs; [
      source-sans-pro
      source-serif-pro
      sarasa-gothic
      libertinus
      et-book
      atkinson-hyperlegible
      gentium-book

      nerd-fonts.jetbrains-mono
      julia-mono

      twemoji-color-font
    ];
  };

  nix = {
    settings = {
      # more like pwn-me-mommy
      accept-flake-config = true;
    };

    registry = {
      darwin.to = {
        type = "path";
        path = inputs.darwin.outPath;
      };
      home-manager.to = {
        type = "path";
        path = inputs.home-manager.outPath;
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
      sixpkgs.to = {
        type = "git";
        ref = "main";
        url = "ssh://git@github.com/sighacks/sixpkgs";
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

  services.dictd.enable = true;

  # services.restic.backups.home = {
  #   paths = [ home ];
  #   repository = "s3:s3.us-east-005.backblazeb2.com/unpledged-prewar-irritable-surfboard-leggings-glacial";
  #   passwordFile = "${home}/.restic/password";
  #   backupPrepareCommand = "source ${home}/.restic/environment";
  #   extraBackupArgs = [
  #     "--dry-run"
  #     "--exclude-caches"
  #     "--exclude-file=${home}/.restic/excludes"
  #   ];
  #   timerConfig = {
  #     # once a week on sunday
  #     Minute = 0;
  #     Hour = 0;
  #     Weekday = 0;
  #   };
  # };

  launchd.user.agents = {
    beorg-sync = {
      serviceConfig = {
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
  };

  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
  system.stateVersion = 7;
}
