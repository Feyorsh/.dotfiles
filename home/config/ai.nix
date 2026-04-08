{ pkgs, ... }:
{
  programs.claude-code = {
    enable = true;
    marketplaces = {
      emacs-skills = pkgs.fetchFromGitHub {
        owner = "xenodium";
        repo = "emacs-skills";
        rev = "de7adccbc4aef5f4e1e7ebc7a487bdcd7f95509a";
        hash = "sha256-ilgWnb3w+6mkeLwy5xkU5iX0NRbguur7iTLVqCu27TA=";
      };
      caveman = pkgs.fetchFromGitHub {
        owner = "JuliusBrussee";
        repo = "caveman";
        tag = "v1.2.0";
        hash = "sha256-asJsuZEaWjDEML/u7L7icX1pP36K83hB3EKGZV6wfiE=";
      };
    };
    settings = {
      enabledPlugins = {
        "emacs-skills@emacs-skills" = true;
        "caveman@caveman" = true;
      };
      permissions = {
        additionalDirectories = [
          "/nix/store/"
        ];
        allow = [
          "Read"
        ];
        deny = [
          "Read(~/Library/**)"
          "Read(~/Mail/**)"
          "Read(~/Personal/Finance/**)"
          "Read(~/Personal/paperwork/**)"
          "Read(~/.ssh/**)"
          "Read(~/.gnupg/**)"
          "Read(~/.password-store/**)"
          "Read(~/.restic/**)"
        ];
      };
    };
  };

  programs.gemini-cli = {
    enable = true;
  };

  programs.emacs.extraPackages = epkgs: (with epkgs; [
    gptel gptel-agent
    agent-shell

    pkgs.claude-agent-acp
  ]);
}
