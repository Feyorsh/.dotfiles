{ lib, inputs, pkgs, home-manager, hyprland, ... }:

{
	ruby = lib.nixosSystem {
		system = "x86_64-linux";
		#specialArgs = inputs; #idk man figure out how to use nix first
		modules = [
			./configuration.nix
			./ruby
			home-manager.nixosModules.home-manager {
				home-manager.useGlobalPkgs = true;
				home-manager.useUserPackages = true;
				home-manager.users.ghuebner = import ./home.nix;
			}
			hyprland.nixosModules.default
			{ programs.hyprland.enable = true; }
		];
	};
}
