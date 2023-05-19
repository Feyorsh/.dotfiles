{
	description = "who let me use Nix";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
		#t2-hardware.url = "github:kekrby/nixos-hardware?dir=apple/t2";
	};

	outputs = { self, nixpkgs, ... }@attrs:
		let 
			system = "x86_64-linux";
		pkgs = import nixpkgs {
			inherit system;
			config.allowUnfree = true;
		};
		lib = nixpkgs.lib;
		in {
			nixosConfigurations = {
				ruby = lib.nixosSystem {
					inherit system;
					#specialArgs = attrs;
					modules = [ ./configuration.nix ];
				};
			};

		};
}
