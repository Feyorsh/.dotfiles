{ pkgs, lib, ... }:
{
  programs.git = {
    enable = true;
    lfs.enable = true;
    delta.enable = true;
    iniContent.delta.magit-delta = {
      line-numbers = false;
    };

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

  home.packages = with pkgs; [
    git-crypt
    (writeShellApplication {
      name = "git-ignore";
      runtimeInputs = [ git ];
      text = ''
        git add --intent-to-add "$@"
        git update-index --skip-worktree "$@"
      '';
    })
    (writeShellApplication {
      name = "git-unignore";
      runtimeInputs = [ git ];
      text = ''
        git update-index --no-skip-worktree "$@"
      '';
    })
  ];

  programs.emacs.extraPackages = epkgs: (with epkgs; [
    magit magit-delta
    forge
  ]);
}
