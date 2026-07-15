{
  description = "doing it to spite the haters (RMS)";
  # $ darwin-rebuild build --flake .#Opal

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    fyshpkgs.url = "github:Feyorsh/fyshpkgs";
    pwnypus.url = "github:Feyorsh/pwnypus/main";

    darwin.url = "github:LnL7/nix-darwin";
    home-manager.url = "github:nix-community/home-manager";
    mac-app-util.url = "github:hraban/mac-app-util";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";

    elfeed-offline.url = "github:Feyorsh/elfeed-offline";
    emacs-tramp-rpc.url = "github:Feyorsh/emacs-tramp-rpc";
  };

  outputs = inputs @ { self, darwin, nixpkgs, fyshpkgs, home-manager, ... }:
    let
      system = "aarch64-darwin";
      inherit (nixpkgs) lib;
      inherit (darwin.lib) darwinSystem;
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            "electron-39.8.10"
          ];
        };
        overlays = [
          fyshpkgs.overlay.${system}

          inputs.emacs-tramp-rpc.overlays.default
          (self: super: {
            emacsPackagesFor =
              emacs:
              ((super.emacsPackagesFor emacs).overrideScope (
                _: esuper: {
                  tramp = esuper.tramp.overrideAttrs (_: rec {
                    version = "2.8.1.3";
                    src = pkgs.fetchurl {
                      url = "https://elpa.gnu.org/packages/tramp-${version}.tar";
                      sha256 = "1jjbgg48q6dlfp9rpn0pla4mlclw60079d51bgnb84q3pv3zdqwj";
                    };
                  });
                }
              ));
          })

          (final: prev: {
            spotify = prev.spotify.overrideAttrs (prev': {
              icon = ./assets/icons/spotify.icns;

              preInstall = ''
                cp $icon Spotify.app/Contents/Resources/Icon.icns
              '';
            });
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
    in
      {
        darwinConfigurations."Opal" = let
          username = "ghuebner";
          specialArgs = { inherit inputs username; };
        in darwinSystem {
          system = "aarch64-darwin";
          inherit specialArgs pkgs;
	        modules = [ ./configuration
		                  home-manager.darwinModules.home-manager
		                  {
                        home-manager.extraSpecialArgs = specialArgs;
			                  home-manager.useGlobalPkgs = true;
			                  home-manager.useUserPackages = true;
			                  home-manager.users.${username} = import ./home;
		                  }
		                  home-manager.darwinModules.home-manager
                      inputs.mac-app-util.darwinModules.default
		                  inputs.pwnypus.darwinModules.chmodbpf
		                  inputs.fyshpkgs.darwinModules.ccache
	                  ];
        };

        # Expose the package set, including overlays, for convenience.
        darwinPackages = self.darwinConfigurations."Opal".pkgs;
      };
}
