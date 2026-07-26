{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    nh
    manix
    nix-search-cli

    nix-output-monitor
    nixpkgs-review
    nixfmt
    nix-prefetch
  ];

  programs.nix-index = {
    enable = true;
    enableFishIntegration = true;
  };

  home.shellAliases = {
    rinse = "${lib.getExe pkgs.nh} home switch ~/.dotfiles";
    lave = "${lib.getExe pkgs.nh} darwin switch ~/.dotfiles";
  };

  programs.fish.functions = {
    nix-hashit = "echo sha256-(nix hash convert --hash-algo sha256 --to base64 $argv)";
    ",," = "string match -r '/nix/store/.*/' $PATH[1]";
    ",,," = "open -na (,,)/Applications/*.app";
    # this nonsense is necessary due to home manager's user environment creating too large of a sandbox-exec profile on macOS.
    rinse-ng = ''
      set path (${lib.getExe pkgs.nh} home switch ~/.dotfiles &| tee /dev/tty &| rg "while waiting for the build environment for '(.*?)'" -o -r '$1')
      if test -n "$path"
          nix-store --realise $path --option sandbox false &>/dev/null
          ${lib.getExe pkgs.nh} home switch ~/.dotfiles
      end
    '';
  };
}
