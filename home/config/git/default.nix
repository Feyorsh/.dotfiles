{ pkgs, lib, ... }:
{
  programs.git = {
    enable = true;
    lfs.enable = true;

    includes = [
      {
        path = ./config;
      }
      {
        path = ./config_school;
        condition = "gitdir:~ghuebner/School/";
      }
    ];
    ignores = lib.splitString "\n" (builtins.readFile ./ignore);
  };

  home.packages = with pkgs; [ git git-lfs git-crypt ];
}
