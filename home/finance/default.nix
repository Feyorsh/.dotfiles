{ pkgs, ... }:
{
  programs.emacs.extraPackages = epkgs: (with epkgs; [
    ledger-mode pkgs.hledger
    (pkgs.writeShellApplication {
      name = "hledger.sh";
      runtimeInputs = [ pkgs.hledger ];
      text = builtins.readFile ./hledger.sh;
    })
  ]);
}
