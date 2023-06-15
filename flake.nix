{
	description = "who let me use Nix";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		hyprland.url = "github:hyprwm/Hyprland";

		sops-nix = {
			url = "github:Mic92/sops-nix";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		emacs-overlay.url = "github:nix-community/emacs-overlay";
	}; #outputs = { self, nixpkgs, ... }@attrs:	I've also seen inputs@ in use
	outputs = inputs @ { self, nixpkgs, home-manager, hyprland, ... }: #, sops-nix }:
		let 
			pkgs = import nixpkgs {
				config.allowUnfree = true;
				overlays = [ (import self.inputs.emacs-overlay) ];
			};
			lib = nixpkgs.lib;
		in {
			nixosConfigurations =
				import ./hosts {
					inherit (nixpkgs) lib;
					inherit inputs pkgs home-manager hyprland;
				};
		};
}
