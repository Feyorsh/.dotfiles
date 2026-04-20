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
    lspServers = {
      python = {
        package = pkgs.basedpyright;
        args = [
          "--stdio"
        ];
        command = "basedpyright-langserver";
        extensionToLanguage = { ".py" = "python"; };
      };
      go = {
        package = pkgs.gopls;
        args = [ "serve" ];
        command = "gopls";
        extensionToLanguage = { ".go" = "go"; };
      };
      rust = {
        package = pkgs.rust-analyzer;
        command = "rust-analyzer";
        extensionToLanguage = { ".rs" = "rust"; };
      };
      cxx = {
        package = pkgs.clang-tools;
        args = [ "--stdio" ];
        command = "clangd";
        extensionToLanguage = { ".c" = "c"; ".h" = "c"; ".hpp" = "c++"; ".cpp" = "c++"; ".cxx" = "c++"; ".hxx" = "c++"; ".cc" = "c++"; };
      };
      zig = {
        package = pkgs.zls;
        command = "zls";
        extensionToLanguage = { ".zig" = "zig"; };
      };
      typst = {
        package = pkgs.tinymist;
        command = "tinymist";
        extensionToLanguage = { ".typ" = "typst"; };
      };
      nix = {
        package = pkgs.nixd;
        command = "nixd";
        extensionToLanguage = { ".nix" = "nix"; };
      };
    };
    settings = {
      hooks = {
        SessionStart = [{
          matcher = "startup";
          hooks = [{
            command = "echo 'caveman mode'";
            type = "command";
          }];
        }];
      };
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
          "Glob"
          "Grep"
          "Bash(ls:*)"
          "Bash(git status:*)"
          "Bash(git log:*)"
          "Bash(git diff:*)"
          "Bash(git show:*)"
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
    memory.source = ./CLAUDE.md;
  };

  programs.gemini-cli = {
    enable = true;
  };

  programs.codex = {
    enable = true;
  };

  programs.emacs.extraPackages = epkgs: (with epkgs; [
    gptel gptel-agent
    agent-shell

    pkgs.claude-agent-acp pkgs.codex-acp
  ]);
}
