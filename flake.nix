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
    debuginfod-zig.url = "github:pwndbg/debuginfod-zig";
  };

  outputs = inputs @ { self, nixpkgs, darwin, home-manager, deploy-rs, ... }:
    let
      pkgsFor = system: import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
        overlays = [
          inputs.emacs-tramp-rpc.overlays.default
        ];
      };
      bootstrap = false;
    in
      {
        homeConfigurations = {
          "peridot" = home-manager.lib.homeManagerConfiguration {
            pkgs = pkgsFor "aarch64-darwin";
            modules = [ ./hosts/peridot/home.nix ];
            extraSpecialArgs = {
              inherit inputs bootstrap;
              username = "ghuebner";
              host = "peridot";
            };
          };
          "diamond" = home-manager.lib.homeManagerConfiguration {
            pkgs = pkgsFor "aarch64-darwin";
            modules = [ ./hosts/diamond/home.nix ];
            specialArgs = {
              inherit inputs bootstrap;
              username = "ghuebner";
              host = "diamond";
            };
          };
          "pallasite" = home-manager.lib.homeManagerConfiguration {
            pkgs = pkgsFor "aarch64-linux";
            modules = [ ./hosts/pallasite/home.nix ];
            extraSpecialArgs = {
              inherit inputs;
              username = "fysh";
              host = "pallasite";
            };
          };
        };

        darwinConfigurations = {
          "peridot" = darwin.lib.darwinSystem {
            pkgs = pkgsFor "aarch64-darwin";
            modules = [ ./hosts/peridot ];
            specialArgs = {
              inherit inputs;
              username = "ghuebner";
              host = "peridot";
            };
          };
          "diamond" = darwin.lib.darwinSystem {
            pkgs = pkgsFor "aarch64-darwin";
            modules = [ ./hosts/diamond ];
            specialArgs = {
              inherit inputs;
              username = "ghuebner";
              host = "diamond";
            };
          };
        };

        nixosConfigurations = {
          "pallasite" = nixpkgs.lib.nixosSystem {
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
            specialArgs = {
              inherit (inputs) disko;
              hostname = "pallasite";
              username = "fysh";
            };
          };
        };

        deploy.nodes.vm = {
          hostname = "pallasite";
          profiles.system = {
            sshUser = "fysh";
            user = "root";
            path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations."pallasite";
          };
          remoteBuild = true;
        };
      };
}
