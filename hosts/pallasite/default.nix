{ pkgs, disko, hostname, username, ... }:

{
  imports = [
    ./disko.nix
    ./vm.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    timeout = 2;
  };

  networking = {
    hostName = hostname;
    interfaces.enp0s1.useDHCP = true;
    interfaces.enp0s2.ipv4.addresses = [
      {
        address = "192.168.3.81";
        prefixLength = 24;
      }
    ];
  };

  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";
  environment.enableAllTerminfo = true;

  users.users."${username}" = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialHashedPassword = "";
  };
  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    coreutils
    findutils
    diffutils
    inetutils
    gawk
    gnused
    gnugrep
    gnutar
    gzip
    xz
    zstd
    unixtools.wall
    unixtools.watch
    psutils

    vim
    wget
    curl
    rsync
    netcat
    socat
    file
    ripgrep
    fd
    jq
    btop
  ];

  programs.bash.enable = true;

  services.openssh = {
    enable = true;
    settings.X11Forwarding = true;
  };
  services.xserver.enable = true;

  nixpkgs = {
    config.allowUnfree = true;
  };
  nix = {
    settings = {
      trusted-users = [ "@wheel" ];
    };

    extraOptions = ''
      experimental-features = nix-command flakes
      builders-use-substitutes = true
    '';

    buildMachines = [
      # ...
    ];
    distributedBuilds = true;
  };

  boot.binfmt = {
    preferStaticEmulators = true;
    emulatedSystems = [ "i386-linux" ]; # x86_64-linux is handled by rosetta
  };

  zramSwap.enable = true;

  system.stateVersion = "26.05";
}
