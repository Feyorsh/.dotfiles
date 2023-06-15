{ config, pkgs, user, ... }: {
	imports = [ 
	./hardware-configuration.nix
	#./work.nix
	''${builtins.fetchGit {
url = "https://github.com/kekrby/nixos-hardware.git"; 
rev = "e964f9f56c01992263c0b8040f989996aa870741";
}}/apple/t2'' ];

	boot = {
		kernelParams = [ "pcie_ports=compat" "intel_iommu=on" "iommu=pt" "mem_sleep_default=s2idle" ]; 
		loader = {
			systemd-boot = {
				enable = true;
				configurationLimit = 5;

			};
			efi = {
				canTouchEfiVariables = true;
				efiSysMountPoint = "/boot/efi";
			};
			timeout = 0;
		};
		initrd = {
			luks.devices = {
				luksroot = {
					device = "/dev/nvme0n1p3";
					preLVM = true;
				};
			};
			# stage 1
			kernelModules = [ "apple_bce" ];
			systemd.enable = true;
			enable = true;
		};
		# stage 2
		kernelModules = [ "apple_touchbar" ];
	};
	# kekrby's nixos-hardware is predicated on an outdated hack that reset the touchbar driver to get suspend to work
	# https://github.com/t2linux/wiki/pull/385 removed this hack after the driver was fixed, but this was never removed in nixos-hardware
	powerManagement = {
		powerUpCommands = "";
		powerDownCommands = "";
	};
	#boot.initrd.kernelModules = [ "apple_bce" ];
	#boot.kernelModules = [ "apple_touchbar" ];

	# `cat /proc/acpi/wakeup` shows that LID is supposed to wakeup from S4, the lowest energy sleep for ACPI. 
	# idk if I really care about having the lid wakeup from s2 though
	services.logind.suspendKey = "hybrid-sleep";
	services.logind.extraConfig = ''
		IdleAction=suspend
		IdleActionSec=10m
	'';
	# trying to figure out how to wake laptop from idle on lid open
	#services.udev.extraRules = ''
		#ACTION=="add", SUBSYSTEM=="usb", DRIVER=="usb", ATTR{power/wakeup}="enabled"
	#'';

	# for some reason this is slow AF
	#boot.plymouth.enable = true;
	#boot.plymouth.theme = "breeze";

	networking = {
		hostName = "ruby";
		wireless.enable = false;
		networkmanager.enable = true;
	};


	# todo: move to modules/hyprland
	environment.sessionVariables.NIXOS_OZONE_WL = "1";

	# todo: add easyeffects config somewhere here
	sound.enable = false;
	security.rtkit.enable = true;
	services.pipewire = {
		enable = true;
		alsa.enable = true;
		alsa.support32Bit = true;
		pulse.enable = true;
	};

	users.users.ghuebner = {
		isNormalUser = true;
		extraGroups = [ "wheel" "input" "video" "netdev" "networkmanager" "docker" ];
	};
	services.getty.autologinUser = "ghuebner";

	time.timeZone = "America/New_York";

	hardware = {
		firmware = [
			(pkgs.stdenvNoCC.mkDerivation {
			 name = "brcm-firmware";

			 buildCommand = ''
			 dir="$out/lib/firmware"
			 mkdir -p "$dir"
			 cp -r ${./firmware}/* "$dir"
					       '';
					       })
					       ];
	       bluetooth.enable = true;
	};

	#services.openssh.enable = false;

	environment.systemPackages = with pkgs; [
		vim
		wget
		git
		# hypr + deps
		xdg-utils
		dunst
		pipewire
		wireplumber
		qt6.qtwayland
		libsForQt5.qt5.qtwayland
		libsForQt5.polkit-kde-agent
		wl-clipboard
		cliphist
		# picker? idk
		rofi-wayland
		# wallpaper
		swww
		# widgets and menu bar
		eww-wayland
		# terminal emulator
		# RH mandated things #
		# backups
		rclone
		restic
		# vpn
		openvpn

		easyeffects

		docker
		git-crypt
	];


	environment.etc = {
		# not sure if this actually does anything, but it uses LDAC so that's good ig
		"wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
			bluez_monitor.properties = {
				["bluez5.enable-sbc-xq"] = true,
				["bluez5.enable-msbc"] = true,
				["bluez5.enable-hw-volume"] = true,
				["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]",
				["bluez5.codecs"] = "[ sbc_xq ldac aac aptx aptx_hd ]",
			}
		'';
	};

	environment.loginShellInit = ''
	[[ "$(tty)" == /dev/tty1 ]] && Hyprland
	'';
}
