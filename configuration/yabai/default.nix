{ config, lib, pkgs, username, ... }:
let
  skhd' = pkgs.skhd.overrideAttrs(prev: {
    buildInputs = (prev.buildInputs or []) ++ [ pkgs.makeWrapper ];
    postInstall = (prev.postInstall or "") + "wrapProgram $out/bin/skhd --set SHELL ${pkgs.bash}/bin/bash";
  });
  userShell = let t = config.users.users.${username}.shell; in "${t}${t.shellPath}";
in
{
  environment.systemPackages = with pkgs; [ yabai skhd' ];

  services.yabai = {
    enable = true;
    enableScriptingAddition = true;
    config = {
      # tiling
      layout = "bsp";
      window_placement = "second_child";
      split_ratio = "0.50";
      split_type = "auto";
      auto_balance = "off";

      # window display
      window_shadow = "float";
      window_opacity = "on";
      active_window_opacity = "1.0";
      normal_window_opacity = "0.90";
      window_zoom_persist = "on";
      window_animation_duration = "0.2";
      window_animation_easing = "ease_out_quint";
      window_opacity_duration = "0.0";
      insert_feedback_color = "0xffd75f5f";

      # displays
      display_arrangement_order = "default";
      window_origin_display = "cursor";

      # padding
      top_padding = "12";
      bottom_padding = "12";
      left_padding = "12";
      right_padding = "12";
      window_gap = "06";
      external_bar = "off:40:0";
      menubar_opacity = "1.0";

      # mouse
      mouse_modifier = "ctrl";
      mouse_action1 = "move";
      mouse_action2 = "resize";
      mouse_drop_action = "stack";
      mouse_follows_focus = "on";
      focus_follows_mouse = "autofocus";
    };
    extraConfig = ''
      yabai -m rule --add app="^GIMP" manage=off
      yabai -m rule --add app="^System Settings" manage=off
      yabai -m rule --add app="^Da Vinci" manage=off
      yabai -m rule --add app="^Finder$" manage=off
      yabai -m rule --add app="^System Information$" manage=off
      yabai -m rule --add app="^Activity Monitor$" manage=off
      yabai -m rule --add app="^Archive Utility$" manage=off
      yabai -m rule --add app="^Font Book$" manage=off
      yabai -m rule --add app="^Calendar$" title="^$" manage=off
      yabai -m rule --add app="^Ghidra" manage=off
      yabai -m rule --add app="^QuickTime" manage=off

      yabai -m rule --add app="^Spotify$" mouse_follows_focus=on scratchpad=spotify grid=11:11:1:1:9:9
      yabai -m rule --add app="^Alacritty$" title="^scratch$" mouse_follows_focus=on scratchpad=term grid=11:11:1:1:9:9

      # tried to autotoggle scratchpads that lost focus, didn't work very well
      # yabai -m signal --add event=window_focused app="!^Spotify$" action="yabai -m query --windows --space | jq -er '.[] | select(.scratchpad!=\"spotify\") | select(.\"is-visible\")' && yabai -m window --toggle spotify"
      # yabai -m signal --add event=window_focused title="!^scratch$" app="!^Alacritty$" action="yabai -m query --windows --space | jq -er '.[] | select(.scratchpad!=\"term\") | select(.\"is-visible\")' && yabai -m window --toggle term"

      yabai -m rule --apply

      yabai -m signal --add event=space_changed action="yabai -m window --focus first"
    '';
  };

  services.skhd = let
    skhd = "${skhd'}/bin/skhd";
    yabai = "${pkgs.yabai}/bin/yabai";
    jq = "${pkgs.jq}/bin/jq";
    alacritty = args: "${pkgs.alacritty}/bin/alacritty msg create-window ${args} || open -a ${pkgs.alacritty}/Applications/Alacritty.app --env SHELL=${userShell} ${lib.optionalString (builtins.stringLength != 0) "--args"} ${args}";

    # rshift = "0x3C";
    lab = "0x2B";
    rab = "0x2F";
    semi = "0x29";
    comm = "0x27";
    plus = "0x18";

    # exit 0 if the space "$1" is on the same display as the focused space, otherwise 1
    # same_display = pkgs.writeShellScript "same_display" ''
    #   NEW_DISPLAY=$(${yabai} -m query --spaces --space "$1" | ${jq} -er '.display')
    #   CUR_DISPLAY=$(${yabai} -m query --spaces --space | ${jq} -er '.display')

    #   [[ "$CUR_DISPLAY" -eq "$NEW_DISPLAY" ]]
    # '';

    focus_right_space = pkgs.writeShellScript "focus_right_space" ''
      if [[ $(${yabai} -m query --spaces --display | ${jq} '.[-1]."has-focus"') == "false" ]]; then ${yabai} -m space --focus next; fi
    '';
    moveto_right_space = pkgs.writeShellScript "moveto_right_space" ''
      if [[ $(${yabai} -m query --spaces --display | ${jq} '.[-1]."has-focus"') == "true" ]]; then ${yabai} -m space --create; fi
      ${yabai} -m window --space next --focus
    '';

    focus_left_space = pkgs.writeShellScript "focus_left_space" ''
      if [[ $(${yabai} -m query --spaces --display | ${jq} '.[0]."has-focus"') == "false" ]]; then ${yabai} -m space --focus prev; fi
    '';
    moveto_left_space = pkgs.writeShellScript "moveto_left_space" ''
      if [[ $(${yabai} -m query --spaces --display | ${jq} '.[0]."has-focus"') == "true" ]]; then ${yabai} -m space --create; IDX="$(${yabai} -m query --spaces --display | ${jq} 'map(select(."native-fullscreen" == 0))[-1].index')"; ${yabai} -m space $IDX --move prev; fi
      ${yabai} -m window --space prev --focus
    '';

    stack_dir = pkgs.writeShellScript "stack_dir" ''
      dir=$1 # north,east,south,west
      
      window=$(${yabai} -m query --windows --window | ${jq} -r '.id')
      
      # Stack this window onto existing stack if possible
      ${yabai} -m window $dir --stack $window
      if [[ $? -ne 0 ]]; then
          # otherwise, float and un-float this window to reinsert it into
          # the bsp tree as a new window
          ${yabai} -m window --insert $dir
          ${yabai} -m window $window --toggle float
          ${yabai} -m window $window --toggle float
      fi
    '';
    
    # move focused window to left space, creating it if it doesn't exist
    # move_win_to_space = pkgs.writeShellScript "move_win_to_space" ''
    #   ${yabai} -m query --spaces --space $1 || (${yabai} -m space --create; ${yabai} -m space --move 
    #   ${same_display} $1 && ${yabai} -m window --space $1 --focus
    # '';

    # # move focused window to right space, creating it if it doesn't exist
    # move_win_to_left_space = pkgs.writeShellScript "move_win_to_left_space" ''
    #   ${same_display} next || ${yabai} -m space --create
    #   ${yabai} -m window --space next --focus
    # '';

    # move_win_to_right_space = pkgs.writeShellScript "move_win_to_right_space" ''
    #   ${same_display} prev || (${yabai} -m space --create; ${yabai} -m space last --move first)
    #   ${yabai} -m window --space prev --focus
    # '';

    # focus the `$1`th on the current display, if it exists.
    focus_nth_space = pkgs.writeShellScript "focus_nth_space" ''
      IDX=$(${yabai} -m query --spaces --display | ${jq} -er ".[$(($1-1))].index") && ${yabai} -m space --focus $IDX
    '';

    # something has gone horribly wrong...
    reset = pkgs.writeShellScript "reset" ''
      launchctl stop org.nixos.yabai 
      launchctl start org.nixos.yabai 

      ${yabai} -m window --scratchpad recover
    '';

    escape = pkgs.writeShellScript "escape" ''
      ${skhd} -k "escape"
    '';

    # remove all padding and gaps in the focused space; marks the space as "fullscreen" by prepending "_" to the label, which allows `windowed_fullscreen` to toggle correctly. Does nothing if there's already a fullscreen window.
    tiled_fullscreen = pkgs.writeShellScript "tiled_fullscreen" ''
      ${yabai} -m query --windows --space | ${jq} -er 'select(.[]; ."has-fullscreen-zoom")' && exit 1

      LABEL=$(${yabai} -m query --spaces --space | ${jq} -er '.label')
      if [[ -z "''${LABEL}" ]] ; then LABEL=$(${yabai} -m query --spaces --space | ${jq} '.id'); fi

      if [[ $LABEL == _* ]] ; then
        ${yabai} -m space --label ''${LABEL#"_"}
      else
        ${yabai} -m space --label "_$LABEL"
      fi

      ${yabai} -m space --toggle padding
      ${yabai} -m space --toggle gap
    '';

    # fit focused window to the entire screen, 
    windowed_fullscreen = pkgs.writeShellScript "windowed_fullscreen" ''
      LABEL=$(${yabai} -m query --spaces --space | ${jq} '.label')
      if [[ ! $LABEL == _* ]] ; then
        ${yabai} -m space --toggle padding
        ${yabai} -m space --toggle gap
      fi

      ${yabai} -m window --toggle zoom-fullscreen
      ${yabai} -m window --focus "$(${yabai} -m query --windows --window | ${jq} -er .id)"
    '';
  in {
    enable = true;
    package = skhd';
    skhdConfig = ''
      # yabai mode map
      :: default : afplay /System/Library/Sounds/Frog.aiff
      :: yabai @ : afplay /System/Library/Sounds/Frog.aiff
      rshift - return ; yabai
      yabai < escape ; default

      # applications
      default, yabai < rshift - t : ${alacritty ""}

      # navigation

      ## windows
      yabai < h : ${yabai} -m window --focus west
      yabai < j : ${yabai} -m window --focus south
      yabai < k : ${yabai} -m window --focus north
      yabai < l : ${yabai} -m window --focus east

      yabai < shift - h : ${yabai} -m window --warp west
      yabai < shift - j : ${yabai} -m window --warp south
      yabai < shift - k : ${yabai} -m window --warp north
      yabai < shift - l : ${yabai} -m window --warp east

      yabai < shift - d : ${yabai} -m space --destroy
      yabai < d : ${yabai} -m window --close

      ### stacks
      yabai < ${semi} : ${yabai} -m window --focus stack.prev
      yabai < ${comm} : ${yabai} -m window --focus stack.next

      ## spaces
      yabai < shift - ${lab} : ${moveto_left_space}
      yabai < shift - ${rab} : ${moveto_right_space}

      yabai < ${lab} : ${focus_left_space}
      yabai < ${rab} : ${focus_right_space}

      yabai < 1 : ${focus_nth_space} 1
      yabai < 2 : ${focus_nth_space} 2
      yabai < 3 : ${focus_nth_space} 3
      yabai < 4 : ${focus_nth_space} 4
      yabai < 5 : ${focus_nth_space} 5
      yabai < 6 : ${focus_nth_space} 6
      yabai < 7 : ${focus_nth_space} 7
      yabai < 8 : ${focus_nth_space} 8
      yabai < 9 : ${focus_nth_space} 9


      ## displays
      yabai < ctrl + shift - ${lab} : ${yabai} -m window --display west --focus
      yabai < ctrl + shift - ${rab} : ${yabai} -m window --display east --focus

      yabai < ctrl - ${lab} : ${yabai} -m display --focus west
      yabai < ctrl - ${rab} : ${yabai} -m display --focus east

      # scratchpads

      yabai < s : ${yabai} -m window --toggle spotify || open -a Spotify
      yabai < t : (${yabai} -m window --toggle term || ${alacritty "-T scratch -o 'window.decorations = \"none\"'"}); ${escape}

      # toggles

      ## float
      yabai < space : ${yabai} -m window --toggle float

      ## fullscreen
      yabai < alt + shift - ${plus} : ${yabai} -m window --toggle native-fullscreen
      yabai < shift - ${plus} : ${windowed_fullscreen}; ${escape}
      yabai < ${plus} : ${tiled_fullscreen}

      ## sticky
      yabai < p : ${yabai} -m window --toggle sticky; \
                  ${yabai} -m window --toggle topmost; \
                  ${yabai} -m window --grid 5:5:4:0:1:1

      yabai < r : ${reset}


      fn - z : osascript -e 'tell application "Spotify" to previous track'
      fn - x : osascript -e 'tell application "Spotify" to playpause'
      fn - c : osascript -e 'tell application "Spotify" to previous track'
    '';
  };

  # https://github.com/koekeishiya/yabai/blob/a4062be1d28c54489400d8b84175fba271423497/README.md?plain=1#L62
  system.defaults.finder.CreateDesktop = lib.mkForce true;

  launchd.user.agents.skhd.serviceConfig.StandardOutPath = "/tmp/skhd_${username}.out.log";
  launchd.user.agents.skhd.serviceConfig.StandardErrorPath = "/tmp/skhd_${username}.err.log";

  launchd.user.agents.remapEjectToPlay.serviceConfig = {
    Program = (pkgs.writeShellScript "remapEject" ''
      /usr/bin/hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0xC000000B8,"HIDKeyboardModifierMappingDst":0xC000000CD}]}'
    '').outPath;
    RunAtLoad = true;
  };
}
