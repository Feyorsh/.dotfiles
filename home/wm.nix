{ inputs, pkgs, lib, config, ... }:

{
  imports = [
    inputs.paneru.homeModules.paneru
  ];

  services.paneru = {
    enable = true;
    settings = {
      options = {
        focus_follows_mouse = true;
        mouse_follows_focus = true;
        reap_empty_workspaces = true;
        preset_column_widths = [ 0.25 0.33 0.5 0.66 0.75 ];
      };

      bindings = {
        quit = "ctrl + alt - q";

        window_focus_north = "alt - k";
        window_focus_east  = "alt - l";
        window_focus_south = "alt - j";
        window_focus_west  = "alt - h";
        window_swap_north  = "alt + shift - k";
        window_swap_east   = "alt + shift - l";
        window_swap_south  = "alt + shift - j";
        window_swap_west   = "alt + shift - h";

        window_nextdisplay     = "alt - ;";
        window_nextdisplaysend = "alt + shift - ;";

        window_resize    = "alt - r";
        window_center    = "alt - c";
        window_fullwidth = "alt - f";
        window_manage    = "alt - .";
      } // lib.mergeAttrsList (map (i':
        let
          i = toString i';
        in {
          "window_virtualnum_${i}"     = "alt - ${i}";
          "window_virtualmovenum_${i}" = "alt + shift - ${i}";
        }) (lib.range 1 9));

      swipe = {
        gesture = {
          fingers_count = 3;
          vertical = false;
        };
      };

      windows = {
        emacs = {
          title = ".*";
          bundle_id = "org.gnu.Emacs";
          width = 1.0;
        };
        quake = {
          title = "quake";
          bundle_id = "com.mitchellh.ghostty";
          grid = "4:4:1:1:2:2";
        };
      };

      decorations.active.border = {
        enabled = true;
        color = "#003b6f";
        width = 2.0;
        radius = 15.0;
      };
    };
  };

  services.skhd = let
    ghostty = args: "open -na ${config.programs.ghostty.package}/Applications/Ghostty.app ${lib.optionalString (builtins.stringLength != 0) "--args"} ${args}";
    reset = pkgs.writeShellScript "reset" ''
      /bin/launchctl stop com.github.karinushka.paneru
      /bin/launchctl stop org.nix-community.home.skhd
      /bin/launchctl start com.github.karinushka.paneru
      /bin/launchctl start org.nix-community.home.skhd
    '';
  in {
    enable = true;
    config = ''
      :: default : afplay /System/Library/Sounds/Frog.aiff
      :: wm @ : afplay /System/Library/Sounds/Frog.aiff
      rshift - return ; wm
      wm < escape ; default
      wm < r : ${reset}

      # applications
      default, wm < rshift - t : ${ghostty ""}
      wm < s : open -a Spotify
      wm < t : ${ghostty "--title=quake --window-decoration=none"} && sleep 0.5 && ${lib.getExe config.services.paneru.package} send-cmd window manage && ${lib.getExe config.services.skhd.package} -k "escape"
    '';
  };
}
