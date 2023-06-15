{ config, lib, pkgs, inputs, user, ... }: {
#	imports = (import ../modules/desktop) ++
#	(import ../modules/editor) ++
#	(import ../modules/browser);


	i18n.defaultLocale = "en_US.UTF-8";
	# console = {
	#   font = "Lat2-Terminus16";
	#   keyMap = "us";
	#   useXkbConfig = true; # use xkbOptions in tty.
	# };

	fonts.fontconfig = {
		defaultFonts = {
			emoji = [ "Twitter Color Emoji" ];
		};
	};

	nix = {
		settings = {
			experimental-features = [ "nix-command" "flakes" ];
			auto-optimise-store = true;
		};
		gc = {
			automatic = true;
			dates = "weekly";
		};
	};

	nixpkgs.config = {
		allowUnfree = true;
	};

	system.stateVersion = "23.05";
}
