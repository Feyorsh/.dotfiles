{
  description = "doing it to spite the haters (RMS)";
  # $ darwin-rebuild build --flake .#Aqua

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    fyshpkgs = {
      url = "git+file:///Users/ghuebner/Personal/fyshpkgs?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pwnypus = {
      url = "github:Feyorsh/pwnypus/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
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
  };

  outputs = inputs @ { self, darwin, nixpkgs, fyshpkgs, home-manager, ... }:
    let
      system = "aarch64-darwin";
      inherit (darwin.lib) darwinSystem;
      pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
        overlays = [
          fyshpkgs.overlay.${system}
          (final: prev: {
            spotify = prev.spotify.overrideAttrs (prev': {
              icon = ./assets/icons/spotify.icns;

              preInstall = ''
                cp $icon Spotify.app/Contents/Resources/Icon.icns
              '';
            });

            alacritty = prev.alacritty.overrideAttrs (prev': {
              icon = ./assets/icons/alacritty.icns;

              preInstall = ''
                cp $icon extra/osx/Alacritty.app/Contents/Resources/alacritty.icns
              '';
            });
	        })
        ];
      };
    in
      {
        darwinConfigurations."Aqua" = let
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
		                  inputs.pwnypus.darwinModules.xquartz
	                  ];
        };

        # Expose the package set, including overlays, for convenience.
        darwinPackages = self.darwinConfigurations."Aqua".pkgs;
      };
}
