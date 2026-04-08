{
  description = "doing it to spite the haters (RMS)";
  # $ darwin-rebuild build --flake .#Opal

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    fyshpkgs.url = "github:Feyorsh/fyshpkgs";
    pwnypus.url = "github:Feyorsh/pwnypus/main";

    darwin.url = "github:LnL7/nix-darwin";
    home-manager.url = "github:nix-community/home-manager";
    mac-app-util.url = "github:hraban/mac-app-util";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
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
        };
        overlays = [
          fyshpkgs.overlay.${system}

          (final: prev: {
            spotify = prev.spotify.overrideAttrs (prev': {
              icon = ./assets/icons/spotify.icns;

              preInstall = ''
                cp $icon Spotify.app/Contents/Resources/Icon.icns
              '';
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
