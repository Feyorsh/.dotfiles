{ pkgs, ... }:
{
  home.packages = with pkgs; [
    (manix.overrideAttrs (prev: {
      patches = (prev.patches or []) ++ [ (fetchpatch {
        url = "https://patch-diff.githubusercontent.com/raw/nix-community/manix/pull/27.patch";
        hash = "sha256-d+gOQweIUBPJkXENTkIzYNH0iqDMW4CXuweI8wZDydU=";
      }) ];
    }))
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

  programs.fish.functions = {
    nix-hashit = "echo sha256-(nix hash convert --hash-algo sha256 --to base64 $argv)";
    nix_shell_packages = ''
        if [ $SHLVL -ge 2 ]
            for p in $PATH
                if not string match -qgr "/nix/store/.*?-(?<pname>.*)-\d*\.\d*\.\d*/" $p; or [ $pname = "kitty" ]
                    continue
                end
                echo $pname
            end
        end
      '';
    ",," = "string match -r '/nix/store/.*/' $PATH[1]";
  };

  # (runCommand "nix-manuals" { nativeBuildInputs = [ docbook2x ]; } ''
  #   mkdir -p $out/info
  #   docbook2texi
  #   ln -s ${pkgs.darwin.xcode_16_1}/* $out/Applications/Xcode.app/
  #  '')
}
