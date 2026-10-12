{ lib, host, ... }:

{
  imports = [
    ./swiss-army.nix
    ./nix.nix
  ];

  networking.hostName = host;

  time.timeZone = lib.mkDefault "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";
}
