{ pkgs, ... }:

{
  imports = [ ../nixos/tailscale.nix ];

  services.tailscale.package = pkgs.tailscale.overrideAttrs (prev: {
    # use builtin ifconfig (BSD) instead of inetutils ifconfig
    postPatch = (prev.postPatch or "") + ''
      sed -e 's,"ifconfig","/sbin/ifconfig",' \
          -i wgengine/router/osrouter/router_userspace_bsd.go
    '';
    doCheck = false;
  });

  # regrettably there is not a great way to do "query 192.168.0.1 and if it returns NXDOMAIN, fallback to 100.100.100.100".
  # in this case, I have a workaround in my ssh_config and otherwise just suck it up and use .lan.
  networking.search = [ "tails.cale" ];
  networking.dns = [ "100.100.100.100" ];
  environment.etc."resolver/tails.cale".text = ''
    search tails.cale
    nameserver 100.100.100.100
  '';
}
