{ username, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ./nethack.nix
    ../../nixos
    (import ../../nixos/remote-builder.nix "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBPrY64vAN0LHRZ3KX3OGtzpYKw5tAfoQdxYO6kxSqgr nixremote@emerald")
    ../../nixos/tailscale.nix
    ../../nixos/sshd.nix
    ../../nixos/xforward.nix
  ];

  networking.hostId = "31815031";

  boot.loader.grub = {
    enable = true;
    zfsSupport = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    mirroredBoots = [
      { devices = [ "nodev" ]; path = "/boot"; }
    ];
  };

  nixpkgs.config.allowUnfree = true;

  users.users."${username}" = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
  };
  services.getty.autologinUser = username;
  security.sudo.extraRules = [{
    users = [ username ];
    commands = [ { command = "/run/current-system/sw/bin/nixos-rebuild"; options = [ "NOPASSWD" ]; } ];
  }];

  users.users = {
    soroush = {
      isNormalUser = true;
    };
    quincy = {
      isNormalUser = true;
    };
  };

  # https://github.com/NixOS/nixpkgs/pull/571297
  nixpkgs.overlays = [
    (final: prev: {
      quartus-prime-lite = prev.quartus-prime-lite.override (p: {
        unwrapped = prev.quartus-prime-lite.unwrapped.override {
          fetchurl = { url, ... }@args: final.fetchurl (args // {
            url = builtins.replaceStrings [ "downloads.intel.com" ] [ "download.altera.com" ] url;
            curlOptsList = [
              "--user-agent"
              "Alterabot/1.0"
            ];
          });
        };
      });
    })
  ];

  environment.systemPackages = with pkgs; [
    quartus-prime-lite
    # (callPackage ./vitis {})
  ];
  environment.enableAllTerminfo = true;

  services.openssh.ports = [ 6969 ]; # acmsoda

  services.tailscale.useRoutingFeatures = "server";
  # https://github.com/NixOS/nixpkgs/issues/411980#issuecomment-3129215477
  system.activationScripts."tailscale-udp-gro-forwarding".text = ''
    ${pkgs.ethtool}/bin/ethtool -K enp2s0 rx-udp-gro-forwarding on rx-gro-list off
  '';

  virtualisation = {
    docker.enable = true;
    podman.enable = true;
    oci-containers.containers = {
      coursemon = {
        image = "docker-archive:/etc/coursemon/image.tar.gz";
        volumes = [
          "/etc/coursemon/config.js:/config.js"
        ];
        workdir = "/";
      };
    };
  };

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "fysh";
    dataDir = "/home/fysh";
    settings = {
      devices = {
        "Peridot" = {
          id = "HM34GOW-JLONODQ-MVMCDVY-T3KP2TG-WB5VHNW-YIEA2W5-5IVWBJQ-VORZ7QK";
          addresses = [
            "tcp://100.64.0.8"
          ];
        };
      };
      folders = {
        "school" = {
          path = "~/backups/school";
          type = "receiveonly";
          devices = [ "Peridot" ];
          versioning = {
            type = "trashcan";
            params.cleanoutDays = "30";
          };
        };
        "elfeed" = {
          path = "~/backups/elfeed";
          type = "receiveonly";
          devices = [ "Peridot" ];
          versioning = {
            type = "trashcan";
            params.cleanoutDays = "30";
          };
        };
      };
    };
  };

  services.forgejo = {
    enable = false;
    settings = {
      server = {
        HTTP_ADDR = "127.0.0.1";
        HTTP_PORT = 4443;
        DOMAIN = "git.nixkingdom.feyor.sh";
        ROOT_URL = "https://git.nixkingdom.feyor.sh/";
        DISABLE_SSH = true;
      };
      session = {
        COOKIE_SECURE = true;
      };
    };
  };

  system.stateVersion = "25.05";
}
