{ lib, pkgs, host, username, ... }:

{
  imports = [
    ./disko.nix
    ./vm.nix
    ../../nixos/swiss-army.nix
    ../../nixos/nix.nix
    (import ../../nixos/remote-builder.nix "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPOxCB2/WSh/ZdWC1rOIojWJR38TftOcFNHlh4y4xe0Y nixremote@pallasite")
    ../../nixos/sshd.nix
    ../../nixos/xforward.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    timeout = 2;
  };

  networking = {
    interfaces.enp0s1.useDHCP = true;
    interfaces.enp0s2.ipv4.addresses = [
      {
        address = "192.168.3.81";
        prefixLength = 24;
      }
    ];
  };

  environment.enableAllTerminfo = true;

  users.users."${username}" = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialHashedPassword = "$y$j9T$EJRSxi9TtW770X2KsUFPB.$a7h0ok45aMvuYaYGz5ZKayy5niuTpFlVBwKsJoHnOu/";
  };
  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    btop
  ];

  # might want to change this if I can figure out how to share tailscale subnet from peridot...
  nix.settings = {
    trusted-substituters = lib.mkForce [];
  };

  virtualisation.podman.enable = true;

  boot.binfmt = {
    preferStaticEmulators = true;
    emulatedSystems = [ "i386-linux" "i686-linux" ]; # x86_64-linux is handled by rosetta
  };

  zramSwap.enable = true;

  system.stateVersion = "26.05";
}
