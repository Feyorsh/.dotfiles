{
  services.openssh = {
    enable = true;
    extraConfig = ''
      PermitRootLogin no
      PasswordAuthentication no
    '';
  };
}
