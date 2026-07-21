{
  description = "doing it to spite the haters (RMS)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    elfeed-offline = {
      url = "github:Feyorsh/elfeed-offline";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-tramp-rpc = {
      url = "github:Feyorsh/emacs-tramp-rpc";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, nixpkgs, darwin, home-manager, ... }:
    let
      inherit (nixpkgs) lib;
      inherit (darwin.lib) darwinSystem;
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            "electron-39.8.10"
          ];
        };
        overlays = [
          inputs.emacs-tramp-rpc.overlays.default
          (self: super: {
            emacsPackagesFor =
              emacs:
              ((super.emacsPackagesFor emacs).overrideScope (
                _: esuper: {
                  tramp = esuper.tramp.overrideAttrs (_: rec {
                    version = "2.8.2";
                    src = pkgs.fetchurl {
                      url = "https://elpa.gnu.org/packages/tramp-${version}.tar";
                      hash = "sha256-FquL+QnjoTpLXQ3vFEF1VGE1kpt/HixDQpOhGUOcNbU=";
                    };
                  });
                }
              ));
          })

          (final: prev: {
            xquartz = prev.xquartz.overrideAttrs (prev': {
              installPhase = builtins.replaceStrings ["--replace xrdb" "--replace xmodmap" "substituteInPlace $out/etc/X11/xinit/privileged_startx.d/20-font_cache \\${"\n"}"] [''--replace '"xrdb"'${""}'' ''--replace '"xmodmap"'${""}'' "#"] prev'.installPhase;
            });
            xorg-server = prev.xorg-server.overrideAttrs (prev': {
              mesonFlags = (prev'.mesonFlags or []) ++ [ "-Dxcsecurity=true" ];
              hardeningDisable = [ "strictflexarrays1" ];
            });
          })
        ];
      };
      username = "ghuebner";
      host = "Peridot";
    in
      {
        homeConfigurations."${username}" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home ];
          extraSpecialArgs = { inherit inputs; };
        };

        darwinConfigurations."${host}" = let
        in darwinSystem {
          inherit pkgs system;
	        modules = [ ./configuration ];
          specialArgs = { inherit inputs username; };
        };
      };
}
