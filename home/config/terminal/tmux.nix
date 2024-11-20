{
  programs.tmux = {
    enable = true;
    prefix = "a";
    keyMode = "vi";
    mouse = true;
    clock24 = true;
    baseIndex = 1;

    extraConfig = ''
      set -g renumber-windows on
      set -g repeat-time 0

      bind-key r source-file ~/.config/tmux/tmux.conf \; display-message "~/.config/tmux/tmux.conf reloaded!"

      # Set new panes to open in current directory
      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"

      bind-key ^ last-window
    '';
  };
}
