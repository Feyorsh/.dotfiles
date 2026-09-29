{
  programs.bash = {
    enable = true;
    historyControl = [ "ignoreboth" "erasedups" ];
  };

  programs.direnv.enableBashIntegration = true;
}
