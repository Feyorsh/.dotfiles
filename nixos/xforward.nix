{
  services.xserver = {
    enable = true;
    displayManager.startx.enable = true;
  };

  services.openssh = {
    settings = {
      X11Forwarding = true;
      X11UseLocalhost = true;
    };
  };
}
