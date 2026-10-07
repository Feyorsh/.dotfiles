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

  environment.etc."resolver/tails.cale".text = "nameserver 100.100.100.100";
}
