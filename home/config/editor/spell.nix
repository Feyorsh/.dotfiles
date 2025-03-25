{ pkgs, ... }:
let
  vale-boilerplate = pkgs.fetchFromGitHub {
    owner = "errata-ai";
    repo = "vale-boilerplate";
    rev = "7282f0551b59e418ad12aeb10a14398b33b560b7";
    hash = "sha256-oItgeu8Y6aIVF1CkN7fBPYDc0RQkS6XWEMgT2THPhaI=";
  };

  aspell' = with pkgs; (aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]));
in
{
  xdg.configFile."vale/.vale.ini" = {
    source = (pkgs.formats.iniWithGlobalSection {}).generate ".vale.ini" {
      globalSection = {
        StylesPath = "styles";
        Vocab = "Blog";
      };
      sections = {
        "*.org" = {
          BasedOnStyles = "Microsoft";
        };
      };
    };
  };
  xdg.configFile."vale/styles" = {
    recursive = true;
    source = "${vale-boilerplate}/styles";
  };

  home.file.".aspell.conf".text = "data-dir ${aspell'}/lib/aspell";

  programs.emacs.extraPackages = epkgs: (with epkgs; [
    jinx aspell'
    (trivialBuild rec {
      pname = "flymake-vale";
      version = "0.0.2";
      src = pkgs.fetchFromGitHub {
        owner = "tpeacock19";
        repo = "flymake-vale";
        rev = "32691d788a378915b98dba81e3af63227a630af3";
        hash = "sha256-Nk89xlogdKJetKyPzFc8nnrXh2o5VPZ756Ng2vIxqsY=";
      };
      packageRequires = [ compat ];
    }) pkgs.vale
  ]);
}
