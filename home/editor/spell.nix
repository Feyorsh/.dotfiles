{ pkgs, ... }:
let
  aspell' = with pkgs; (aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]));
in
{
  home.file.".aspell.conf".text = "data-dir ${aspell'}/lib/aspell";

  programs.emacs.extraPackages = epkgs: (with epkgs; [
    jinx aspell'
  ]);
}
