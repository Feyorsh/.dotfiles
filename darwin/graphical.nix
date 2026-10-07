{
  imports = [ ./xquartz.nix ];

  security.pam.services.sudo_local.touchIdAuth = true;

  services.xquartz = {
    enable = true;
    configureSsh = true;
  };
}
