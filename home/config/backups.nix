{ inputs, config, lib, pkgs, user, home, ... }:
{
  # services.restic = {
  #   enable = true;
  # };

  services.syncthing = {
    enable = true;
    settings = {
      devices = {
        "manta".id = "LY3FZKU-HZ657YG-Q6DXXPL-XOAFTCW-6KB5THO-Q42WL4J-5YWZKZR-MN7RTQP";
        "emerald" = {
          id = "7OFZHZQ-3FATONL-Y2YKENM-IRHDR2O-CJHMTEL-T3I5HQ2-YBF76VJ-ZXR6ZQC";
          addresses = [
            "tcp://100.64.0.5"
          ];
        };
      };
      folders = {
        "manta-inbox" = {
          path = "~/Personal/syncthing/manta/INBOX";
          devices = [ "manta" ];
          versioning = {
            type = "simple";
            params.keep = "3";
          };
        };
        "manta-notes" = {
          path = "~/Personal/syncthing/manta/Note";
          devices = [ "manta" ];
          versioning = {
            type = "simple";
            params.keep = "3";
          };
        };
        "school" = {
          path = "~/School";
          type = "sendonly";
          devices = [ "emerald" ];
        };
        "elfeed" = {
          path = "~/.elfeed";
          type = "sendonly";
          devices = [ "emerald" ];
        };
      };
    };

  };
}
