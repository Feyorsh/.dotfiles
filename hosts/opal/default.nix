{ nixos-apple-silicon, host, username, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    nixos-apple-silicon.nixosModules.apple-silicon-support

    ../../nixos
    ../../nixos/sshd.nix
    ../../nixos/tailscale.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
  services.libinput.enable = true;

  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";

  environment.enableAllTerminfo = true;

  users.users."${username}" = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  environment.systemPackages = with pkgs; [
    btop
  ];

  system.stateVersion = "26.11";
}

