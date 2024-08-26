{ pkgs, ... }:
{
  home.file.".nethackrc".source = ./nethackrc;

  home.packages = with pkgs; [ nethack ];
}
