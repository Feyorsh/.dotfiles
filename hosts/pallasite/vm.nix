{ lib, modulesPath, username, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  services.qemuGuest.enable = true;

  virtualisation.rosetta.enable = true;

  boot.kernelParams = [
    "console=hvc0"
    # M4 macs seem to falsely advertise support for some vector instructions; disable them.
    "arm64.nosve" "arm64.nosme"
  ];
  systemd.services."serial-getty@hvc0".enable = true;

  # https://github.com/crc-org/vfkit/issues/242#issuecomment-2598255241
  networking.useNetworkd = true;
  systemd.network = {
    enable = true;
    networks."10-uplink" = {
      matchConfig.Name = lib.mkDefault "en* eth*";
      networkConfig.DHCP = lib.mkDefault "ipv4";
      dhcpV4Config.ClientIdentifier = lib.mkDefault "mac";
    };
  };

  services.chrony = {
    enable = true;
    extraConfig = ''
      refclock RTC /dev/rtc0:utc
      makestep 1 -1
    '';
    enableRTCTrimming = false;
  };

  # TODO ???
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "sr_mod"
  ];
  boot.initrd.kernelModules = lib.mkDefault [ ];
  boot.extraModulePackages = lib.mkDefault [ ];

  fileSystems = {
    "/home/${username}" = {
      device = "/dev/hda2";
      fsType = "ext3";
      options = [ "data=journal" ];
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
