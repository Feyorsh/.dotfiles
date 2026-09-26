{ pkgs, lib, ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    includes = [ "temp.conf" ];
    settings = {
      "*" = {
        ForwardAgent = false;
        AddKeysToAgent = "no";
        Compression = false;
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        StrictHostKeyChecking = "accept-new";
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
        WarnWeakCrypto = "no-pq-kex";
      };
      "emerald" = {
        User = "fysh";
        Port = 6969;
        SendEnv = "DGLAUTH";
      };
      "vermillion" = {
        User = "fysh";
        Port = 6969;
      };
      "router" = {
        HostName = "192.168.1.1";
        User = "root";
      };
      "steamlink" = {
        User = "root";
      };
    } // (lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
      "pallasite" = {
        HostName = "192.168.64.9";
        User = "fysh";
        ForwardX11 = true;
      };
      "cs425-b2??" = {
        User = "cs425";
        HostName = "fa26-%h.cs.illinois.edu";
      };
      "pluto" = {
        HostName = "192.168.2.1";
        UserKnownHostsFile = "/dev/null";
        HostKeyAlias = "plutosdr";
        StrictHostKeyChecking = false;
        CheckHostIP = false;
        ChallengeResponseAuthentication = false;
        User = "root";
      };
    });
  };
}
