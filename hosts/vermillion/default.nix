{ username, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../nixos
    (import ../../nixos/remote-builder.nix "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEFK0+egnmN8Qg+j6EiD3octmRgVNfJxvlvxJzn4dio/ nixremote@vermillion")
    ../../nixos/tailscale.nix
    ../../nixos/sshd.nix
    ../../nixos/xforward.nix
  ];

  networking.hostId = "386103C3";

  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.useOSProber = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };
  services.getty.autologinUser = username;

  virtualisation.podman.enable = true;

  services.tailscale.useRoutingFeatures = "server";

  services.openssh.ports = [ 6969 ]; # acmsoda

  hardware.firmware = [ pkgs.linux-firmware ]; # necessary?

  programs.wayvnc.enable = true;

  programs.steam.enable = true;
  nixpkgs.config.allowUnfree = true;

  services.udev.packages = [ pkgs.usb-blaster-udev-rules ];
  services.udev.extraRules = ''
    # USB-Blaster III
    ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="6020", TAG+="uaccess"
    ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="6022", TAG+="uaccess"
    ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="6023", TAG+="uaccess"
    ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="6024", TAG+="uaccess"
    ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="6025", TAG+="uaccess"
    ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="6026", TAG+="uaccess"
    ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="602C", TAG+="uaccess"
    ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="602D", TAG+="uaccess"
    ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="602E", TAG+="uaccess"
  '';

  system.stateVersion = "25.11";
}
