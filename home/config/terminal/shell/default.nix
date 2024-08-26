{
  imports = [ ./fish.nix ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config = {
      global = {
        hide_env_diff = true;
      };
    };
  };

  programs.less = {
    enable = true;
    keys = ''
      h noaction 1\e(
      H noaction 50\e(
      l noaction 1\e)
      L noaction 50\e)
      J forw-scroll
      K back-scroll
    '';
  };
}
