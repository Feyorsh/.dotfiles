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

  # prioritize DNS from router over MagicDNS
  networking.search = [ "lan" "tails.cale" ];
  environment.etc."resolver/lan".text = ''
    nameserver 192.168.1.1
    timeout 1
  '';
  environment.etc."resolver/tails.cale".text = ''
    nameserver 100.100.100.100
    timeout 2
  '';
}
