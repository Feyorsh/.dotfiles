# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
	imports = [ #./home.nix
#		<home-manager/nixos>
		./hardware-configuration.nix ''${builtins.fetchGit {
url = "https://github.com/kekrby/nixos-hardware.git"; 
rev = "e964f9f56c01992263c0b8040f989996aa870741";
}}/apple/t2'' ];

# Use the systemd-boot EFI boot loader.
	boot.loader.systemd-boot.enable = true;
	boot.loader.systemd-boot.configurationLimit = 5;
	boot.loader.efi.canTouchEfiVariables = true;
	boot.loader.efi.efiSysMountPoint = "/boot/efi";
	boot.loader.timeout = 2;

	boot.initrd.enable = true;
	boot.initrd.luks.devices = {
		luksroot = {
			device = "/dev/nvme0n1p3";
			preLVM = true;
		};
	};

	networking.hostName = "ruby"; # Define your hostname.
# Pick only one of the below networking options.
#networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
		networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

# Set your time zone.
		time.timeZone = "America/Boston";

# Configure network proxy if necessary
# networking.proxy.default = "http://user:password@proxy:port/";
# networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

# Select internationalisation properties.
	i18n.defaultLocale = "en_US.UTF-8";
# console = {
#   font = "Lat2-Terminus16";
#   keyMap = "us";
#   useXkbConfig = true; # use xkbOptions in tty.
# };

nix.settings.experimental-features = [ "nix-command" "flakes" ];

# Enable CUPS to print documents.
# services.printing.enable = true;

# Enable sound.
sound.enable = false;
security.rtkit.enable = true;
services.pipewire = {
	enable = true;
	alsa.enable = true;
	alsa.support32Bit = true;
	pulse.enable = true;
};
	hardware.firmware = [
		(pkgs.stdenvNoCC.mkDerivation {
		 name = "brcm-firmware";

		 buildCommand = ''
		 dir="$out/lib/firmware"
		 mkdir -p "$dir"
		 cp -r ${./secrets/firmware}/* "$dir"
				       '';
				       })
				       ];
# Enable touchpad support (enabled default in most desktopManager).
# services.xserver.libinput.enable = true;

# Define a user account. Don't forget to set a password with ‘passwd’.
users.users.ghuebner = {
	isNormalUser = true;
	extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
	packages = with pkgs; [
		firefox-wayland
		thunderbird
	];
};
services.getty.autologinUser = "ghuebner";

# home-manager.users.ghuebner = { pkgs, ... }: {
# home.packages = with pkgs; [ htop ];
# };

# List packages installed in system profile. To search, run:
# $ nix search wget
environment.systemPackages = with pkgs; [
	vim
	wget
	git
	# hypr + deps
	hyprland
	xdg-desktop-portal-hyprland
	dunst
	pipewire
	wireplumber
	qt6.qtwayland
	libsForQt5.qt5.qtwayland
	libsForQt5.polkit-kde-agent
	# picker? idk
	rofi-wayland
	# wallpaper
	swww
	# widgets and menu bar
	eww-wayland
	# terminal emulator
	wezterm
];
programs.hyprland.enable = true;
environment.loginShellInit = ''
[[ "$(tty)" == /dev/tty1 ]] && Hyprland
'';

# Some programs need SUID wrappers, can be configured further or are
# started in user sessions.
# programs.mtr.enable = true;
# programs.gnupg.agent = {
#   enable = true;
#   enableSSHSupport = true;
# };

# List services that you want to enable:

# Enable the OpenSSH daemon.
# services.openssh.enable = true;

# Open ports in the firewall.
# networking.firewall.allowedTCPPorts = [ ... ];
# networking.firewall.allowedUDPPorts = [ ... ];
# Or disable the firewall altogether.
# networking.firewall.enable = false;

# Copy the NixOS configuration file and link it from the resulting system
# (/run/current-system/configuration.nix). This is useful in case you
# accidentally delete configuration.nix.
# system.copySystemConfiguration = true;

# This value determines the NixOS release from which the default
# settings for stateful data, like file locations and database versions
# on your system were taken. It’s perfectly fine and recommended to leave
# this value at the release version of the first install of this system.
# Before changing this value read the documentation for this option
# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
		system.stateVersion = "23.05"; # Did you read the comment?

}
