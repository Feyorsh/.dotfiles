{ pkgs, ... }:

{
  # essential packages; my swiss army chainsaw
  # these can and should be shadowed by user packages where sensible
  environment.systemPackages = with pkgs; [
    coreutils
    findutils
    diffutils
    inetutils
    gawk
    gnused
    gnutar
    gzip
    xz
    zstd
    psutils

    file
    git
    wget
    curl
    rsync
    netcat
    socat
    ripgrep
    fd
    jq
  ];

  programs.vim.enable = true;
  programs.bash.enable = true;
}
