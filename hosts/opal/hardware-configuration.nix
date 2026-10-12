{ lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  hardware.asahi = {
    enable = true;
    peripheralFirmwareDirectory = pkgs.linkFarm "vendorfw" [
      {
        name = "firmware.cpio";
        path = pkgs.requireFile {
          name = "firmware.cpio";
          hash = "sha256-ORemZBhd8ELpbj7qG7RlxgARCby1+o6PKdZH6Jpb/jI=";
          message = ''
            nix-prefetch-url file:///boot/vendorfw/firmware.cpio
          '';
          meta.license = lib.licenses.unfreeRedistributableFirmware;
        };
      }
    ];
  };

  boot.initrd.availableKernelModules = [ "usb_storage" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/3f27b823-b134-453a-87ba-486e176ce5de";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/3f27b823-b134-453a-87ba-486e176ce5de";
      fsType = "btrfs";
      options = [ "subvol=nix" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/3f27b823-b134-453a-87ba-486e176ce5de";
      fsType = "btrfs";
      options = [ "subvol=home" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/3F06-0A1E";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  fileSystems."/swap" =
    { device = "/dev/disk/by-uuid/3f27b823-b134-453a-87ba-486e176ce5de";
      fsType = "btrfs";
      options = [ "subvol=swap" ];
    };

  swapDevices = [ { device = "/swap/swapfile"; } ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
