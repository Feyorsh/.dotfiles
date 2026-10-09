{ inputs, host, lib, pkgs, ... }:
let
  inherit (inputs.self) darwinConfigurations;
  manpages = "${darwinConfigurations."${host}".config.system.path}/share/man";
  mkDarwinManCache = pkgs.runCommandLocal "nix-darwin-man-cache" {
    nativeBuildInputs = [ pkgs.man ];
  } ''
      echo "MANDB_MAP ${manpages} $out" > man.conf

      mandb -C man.conf --no-straycats --create ${manpages}
    '';
in
{
  home.packages = with pkgs; [
    man-pages
    gcc.info
    binutils.info
  ];

  manual.manpages.enable = false;
  programs.man = {
    package = pkgs.man;
    generateCaches = true;
    man-db.extraConfig = lib.optionalString (builtins.hasAttr host darwinConfigurations) ''
      MANDB_MAP /run/current-system/sw/share/man ${mkDarwinManCache}
    '';
  };
  programs.info.enable = true;
}
