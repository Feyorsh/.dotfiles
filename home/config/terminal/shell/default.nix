{ config, pkgs, ... }:
{
  imports = [ ./fish.nix ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config = {
      global = {
        hide_env_diff = true;
      };
    };
  };

  programs.less = {
    enable = true;
    config = ''
      h noaction 1\e(
      H noaction 50\e(
      l noaction 1\e)
      L noaction 50\e)
      J forw-scroll
      K back-scroll
    '';
  };
  home.sessionVariables.PAGER = "less -FR";

  programs.zoxide.enable = true;
  home.sessionVariables._ZO_DATA_DIR = config.xdg.dataHome;

  home.packages = with pkgs; [
    (writeShellApplication {
      name = "hydrate";
      runtimeInputs = [ restic pass ];
      text = builtins.readFile ./hydrate;
    })
    cheat
  ];
}
