{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    (writeShellApplication {
      name = "direnv-dwim";
      runtimeInputs = [ direnv jq ];
      text = ''
        envrc=$(direnv status --json | jq -r '.state.foundRC.path')
        if [ "$envrc" == "null" ]; then
          echo -e "nix_direnv_manual_reload\nuse nix" > .envrc
          direnv allow
        else
          case "$(direnv status --json | jq -r '.state.foundRC.allowed')" in
            0) touch "$envrc" ;; # allowed
            1) direnv allow ;;   # undecided
            2) return 0 ;;       # blocked by user
            *) echo "unknown direnv allowed state, ignoring..." >&2
               return 0 ;;
          esac
        fi
        direnv exec . nix-direnv-reload
      '';
    })
  ];

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  programs.zoxide.enable = true;
  home.sessionVariables._ZO_DATA_DIR = config.xdg.dataHome;

  home.file.".hushlogin".text = "";
}
