{
  description = "doing it to spite the haters (RMS)";
  # $ darwin-rebuild build --flake .#Aqua

  inputs = {
    nix.url = "github:NixOS/nix?ref=2.19.1";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    fyshpkgs = {
      url = "git+file:///Users/ghuebner/Personal/fyshpkgs";
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

  outputs = inputs@{ self, darwin, nixpkgs, fyshpkgs, nix, home-manager }:
    let
      system = "aarch64-darwin";
      inherit (darwin.lib) darwinSystem;
      #linuxSystem = builtins.replaceStrings [ "darwin" ] [ "linux" ] system;
      darwin-builder = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          "${nixpkgs}/nixos/modules/profiles/macos-builder.nix"
          {
            virtualisation.host.pkgs = nixpkgs.legacyPackages.aarch64-darwin;
            system.nixos.revision = nixpkgs.lib.mkForce null;
          }
        ];
      };
      pkgs = import nixpkgs {
        inherit system;
	      config = { allowUnfree = true; };
	      overlays = [
          (final: prev: {
            spotify = prev.spotify.overrideAttrs (prev': {
              #icon = prev.fetchurl {
                #url = "https://raw.githubusercontent.com/Dav-ej/Custom-Big-Sur-Icons/master/Icons/Spotify_Dark_Alt.icns";
                #name = "${prev'.pname}.icns";
                #sha256 = "BqMxC9Mvrr9QOyCVP8RfVK/gZSkpUQjrbwJ10i/BWow=";
              #};
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

             postInstall = prev'.postInstall + ''
               cp $icon $out/Applications/Emacs.app/Contents/Resources/Emacs.icns
             '';
           });
           nixVersions = (prev.nixVersions.extend(self: super: {
             master = nix.packages.aarch64-darwin.nix;
           }));
	  }) ];
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
      fpkgs = import fyshpkgs { inherit pkgs; };
    in
      {
        darwinConfigurations."Aqua" = darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit fpkgs; };
          inherit pkgs;
	        modules = [ ./configuration.nix
		                  home-manager.darwinModules.home-manager
		                  {
                        #inherit pkgs;
			                  #nixpkgs = pkgs;
                        home-manager.extraSpecialArgs = { inherit fpkgs; };
			                  home-manager.useGlobalPkgs = true;
			                  home-manager.useUserPackages = true;
			                  home-manager.users.ghuebner = import ./home.nix;
		                  }
                      # linux-builder
                      # {
                      #   nix.distributedBuilds = true;
                      #   nix.buildMachines = [{
                      #     hostName = "builder@localhost";
                      #     system = "aarch64-linux";
                      #     maxJobs = 4;
                      #     supportedFeatures = [ "kvm" "benchmark" "big-parallel" ];
                      #   }];

                      #   launchd.daemons.darwin-builder = {
                      #     command = "${darwin-builder.config.system.build.macos-builder-installer}/bin/create-builder";
                      #     serviceConfig = {
                      #       KeepAlive = true;
                      #       RunAtLoad = true;
                      #       StandardOutPath = "/var/log/darwin-builder.log";
                      #       StandardErrorPath = "/var/log/darwin-builder.log";
                      #       WorkingDirectory = "/etc/nix";
                      #     };
                      #   };
                      # }
	                  ];
        };

        # Expose the package set, including overlays, for convenience.
        # darwinPackages = self.darwinConfigurations."Aqua".pkgs;
      };
}
