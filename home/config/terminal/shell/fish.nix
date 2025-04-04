{ config, pkgs, ... }:
{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g async_prompt_functions _pure_prompt_git

      set fish_cursor_default     block      blink
      set fish_cursor_insert      line       blink
      set fish_cursor_replace_one underscore blink
      set fish_cursor_visual      block

      fish_vi_key_bindings
    '';
    shellAliases = {
      rinse = "cd ~/.dotfiles; darwin-rebuild switch --flake .#Aqua --option sandbox false; cd -";
      mkown = "sudo chown -R $USER:(id -gn)";
    };
    shellAbbrs = {
      dd = {
       position = "anywhere";
       expansion = "dd status=progress";
      };
    };
    functions = {
      which = "readlink -f (command which $argv)";
      cheat = "command cheat -c $argv | $PAGER";
      mkcd = "mkdir -p $argv && cd $argv";
      alert = "command $argv; afplay (random choice ~/Profile/Sounds/*) &";
      dugb = "du -h -d 1 $argv | grep -P 'G\t'";
    };
    plugins = [
      { name = "pure"; src = pkgs.fishPlugins.pure.src; }
      { name = "fishplugin-async-prompt"; src = pkgs.fishPlugins.async-prompt.src; }
    ];
  };
}
