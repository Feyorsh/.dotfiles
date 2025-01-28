{ lib, darwinConfig, username, ... }:
let
  shell = lib.getExe darwinConfig.users.users.${username}.shell;
in
{
  programs.alacritty = {
    enable = true;
    settings = {
      font.size = 18;
      selection.save_to_clipboard = true;
      terminal = {
        shell = {
          program = shell;
          args = [ "-i" ]; # NOT a login shell, that results in `path_helper` causing problems
        };
      };
      env = {
        SHELL = shell;
      };
    };
  };
}
