{
	description = "who let me use Nix";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		hyprland.url = "github:hyprwm/Hyprland";

		emacs-overlay.url = "github:nix-community/emacs-overlay";
	};
	outputs = inputs @ { self, nixpkgs, home-manager, hyprland, ... }:
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
