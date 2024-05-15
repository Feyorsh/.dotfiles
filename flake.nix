{
  description = "doing it to spite the haters (RMS)";
  # $ darwin-rebuild build --flake .#Aqua

  inputs = {
    nix.url = "github:NixOS/nix?ref=2.19.1";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    fyshpkgs = {
      url = "git+file:///Users/ghuebner/Personal/fyshpkgs?ref=main";
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
  };

  outputs = flakes @ { self, darwin, nixpkgs, fyshpkgs, nix, home-manager }:
    let
      system = "aarch64-darwin";
      inherit (darwin.lib) darwinSystem;
      pkgs = import nixpkgs {
        inherit system;
	      config = { allowUnfree = true; };
	      overlays = [
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
           emacs29-macport = prev.emacs29-macport.overrideAttrs (prev': {
             icon = ./assets/icons/emacs.icns;
             patches = prev'.patches ++ [ (final.fetchpatch {
               url = "https://raw.githubusercontent.com/railwaycat/homebrew-emacsmacport/911412ca8ea2671c1122bc307a1cd0740005a55d/patches/emacs-mac-title-bar-9.1.patch";
               sha256 = "+SGySdRPFuw+yOuTwGiH4tLYqk4bh+2BRT46jUGEfuY=";
             }) ];

             configureFlags = (prev'.configureFlags or []) ++ [
               "--with-xwidgets"
             ];
             buildInputs = (prev'.buildInputs or []) ++ [
               final.darwin.apple_sdk_11_0.frameworks.WebKit
             ];
             postInstall = prev'.postInstall + ''
               cp $icon $out/Applications/Emacs.app/Contents/Resources/Emacs.icns
             '';
           });
           nixVersions = (prev.nixVersions.extend(self: super: {
             master = nix.packages.aarch64-darwin.nix;
           }));
	  }) ];
      };
      fpkgs = import fyshpkgs { inherit pkgs; };
    in
      {
        darwinConfigurations."Aqua" = darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit fpkgs; };
          inherit pkgs;
	        modules = [ (import ./configuration.nix flakes)
		                  home-manager.darwinModules.home-manager
		                  {
                        home-manager.extraSpecialArgs = { inherit fpkgs; };
			                  home-manager.useGlobalPkgs = true;
			                  home-manager.useUserPackages = true;
			                  home-manager.users.ghuebner = import ./home.nix;
		                  }
	                  ];
        };

        # Expose the package set, including overlays, for convenience.
        darwinPackages = self.darwinConfigurations."Aqua".pkgs;
      };
}
