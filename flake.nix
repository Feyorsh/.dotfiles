{
  description = "doing it to spite the haters (RMS)";
  # $ darwin-rebuild build --flake .#Aqua

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-tny.url = "github:tnytown/nixpkgs-overlay-tny";
    darwin = {
	    url = "github:LnL7/nix-darwin";
	    inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, darwin, nixpkgs, nixpkgs-tny, home-manager }:
    let
      nixpkgsConfig = {
	      config = { allowUnfree = true; };
	      overlays = [ (final: prev:
          let packagesFrom = inputAttr: inputAttr.packages.${final.system};
          in { inherit (packagesFrom nixpkgs-tny) emacsMacport; }) ];
        #	  overlays = attrValues self.overlays ++ singleton (
        #			  final: prev: (optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
        #				  inherit (final.pkgs-x86)
        #				  idris2
        #				  nix-index
        #				  niv
        #				  purescript;
        #				  })
        #			  );
      };
    in
      {
        darwinConfigurations."Aqua" = darwin.lib.darwinSystem {
	        system = "aarch64-darwin";
	        modules = [ ./configuration.nix
		                  home-manager.darwinModules.home-manager
		                  {
			                  nixpkgs = nixpkgsConfig;
			                  home-manager.useGlobalPkgs = true;
			                  home-manager.useUserPackages = true;
			                  home-manager.users.ghuebner = import ./home.nix;
		                  }
	                  ];
        };

        # Expose the package set, including overlays, for convenience.
        # darwinPackages = self.darwinConfigurations."Aqua".pkgs;
      };
}
