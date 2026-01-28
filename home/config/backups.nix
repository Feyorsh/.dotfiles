{ inputs, config, lib, pkgs, user, home, ... }:
{
  # services.restic = {
  #   enable = true;
  # };

  services.syncthing = {
    enable = true;
    settings = {
      devices = {
        "manta" = "LY3FZKU-HZ657YG-Q6DXXPL-XOAFTCW-6KB5THO-Q42WL4J-5YWZKZR-MN7RTQP";
      };
      folders = {
        "manta" = {
          path = "~/Personal/syncthing/manta";
          devices = [ "manta" ];
          versioning = {
            type = "simple";
            params.keep = "3";
          };
        };
      };
    };

  };
}
