{ pkgs, lib, ... }:
{
  programs.git = {
    enable = true;
    lfs.enable = true;
    difftastic.enable = true;
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
    attributes = [
      "*.pdf binary"
      "*.svg binary"
    ];
  };

  programs.gh.enable = true;

  home.packages = with pkgs; [
    git-crypt
    delta
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
    git-branchless
  ];

  programs.emacs.extraPackages = epkgs: (with epkgs; [
    magit magit-delta
    (forge.overrideAttrs (prev: rec {
      version = "0.5.0";
      src = pkgs.fetchFromGitHub {
        owner = "magit";
        repo = prev.pname;
        rev = "refs/tags/v${version}";
        hash = "sha256-/BseEuiEbBbUtkulDct6nh+u+wWOxSuwwxhjO9hHego=";
      };
    }))
  ]);
}
