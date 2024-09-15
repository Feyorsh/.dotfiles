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

  programs.emacs.extraPackages = epkgs: (with epkgs; [
    (magit.overrideAttrs(prev: rec {
      patches = (prev.patches or []) ++ [
        (pkgs.fetchpatch {
          url = "https://github.com/magit/magit/commit/f31cf79b2731765d63899ef16bc8be0fa2cc7d32.patch";
          sha256 = "sha256-1UClOoJ+M33dzmmq2HgM31mNxtczjw+ekL5GuXBF3d4=";
        })
      ];
    }))
    forge
  ]);
}
