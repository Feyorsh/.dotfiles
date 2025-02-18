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
      dugb = "du -h -d 1 $argv | grep -P 'G\t'";
      rinse = "cd ~/.dotfiles; darwin-rebuild switch --flake .#Aqua --option sandbox false; cd -";
      alert = "command $argv; afplay (random choice ~/Profile/Sounds/*) &";
    };
    functions = {
      nix_shell_packages = ''
        if [ $SHLVL -ge 3 ]
            for p in $PATH
                if not string match -qgr "/nix/store/.*?-(?<pname>.*)-\d*\.\d*\.\d*/" $p; or [ $pname = "kitty" ]
                    break
                end
                echo $pname
            end
        end
      '';
    };
    plugins = [
      { name = "pure"; src = pkgs.fishPlugins.pure.src; }
      { name = "fishplugin-async-prompt"; src = pkgs.fishPlugins.async-prompt.src; }
    ];
  };
}
