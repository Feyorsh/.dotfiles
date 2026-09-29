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
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
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
    paneru = {
      url = "github:karinushka/paneru";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixcord = {
      url = "github:4evy/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, nixpkgs, darwin, home-manager, deploy-rs, ... }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
        overlays = [
          inputs.emacs-tramp-rpc.overlays.default
        ];
      };
      username = "ghuebner";
      host = "Peridot";
      vmHost = "pallasite";
      vmUser = "fysh";
      bootstrap = false;
    in
      {
        homeConfigurations."${username}" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home ];
          extraSpecialArgs = { inherit inputs username bootstrap; };
        };

        darwinConfigurations."${host}" = darwin.lib.darwinSystem {
          inherit pkgs system;
	        modules = [ ./configuration ];
          specialArgs = { inherit inputs username host bootstrap; };
        };

        nixosConfigurations."${vmHost}" = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";

          modules = [
            ./hosts/pallasite
            ./hosts/pallasite/vm.nix

            {
              nixpkgs.overlays = [
                (self: super: {
                  # https://github.com/NixOS/nixpkgs/issues/392673
                  neattle = super.neattle.overrideAttrs (p:
                    self.lib.optionalAttrs self.stdenv.hostPlatform.isStatic {
                      env.CCPIC = "-fPIC";
                    }
                  );
                  # https://github.com/NixOS/nixpkgs/issues/366902
                  qemu-user = super.qemu-user.overrideAttrs (p:
                    self.lib.optionalAttrs self.stdenv.hostPlatform.isStatic {
                      configureFlags = (p.configureFlags or []) ++ [ "--disable-pie" ];
                    }
                  );
                })
              ];
            }
          ];
          specialArgs = { inherit (inputs) disko; hostname = vmHost; username = vmUser; };
        };

        deploy.nodes.vm = {
          hostname = vmHost;
          profiles.system = {
            sshUser = vmUser;
            user = "root";
            path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations."${vmHost}";
          };
          remoteBuild = true;
        };
      };
}
