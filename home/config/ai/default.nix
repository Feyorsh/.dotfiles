{ pkgs, lib, ... }:
let
  caveman = pkgs.fetchFromGitHub {
    owner = "JuliusBrussee";
    repo = "caveman";
    tag = "v1.6.0";
    hash = "sha256-m7HhCW4fXU5pIYRWVP6cvSYUkDHt8R90D9UI3tT7euk=";
  };
  emacs-skills = pkgs.fetchFromGitHub {
    owner = "xenodium";
    repo = "emacs-skills";
    rev = "de7adccbc4aef5f4e1e7ebc7a487bdcd7f95509a";
    hash = "sha256-ilgWnb3w+6mkeLwy5xkU5iX0NRbguur7iTLVqCu27TA=";
  };
in
{
  programs.claude-code = {
    enable = true;
    marketplaces = {
      inherit caveman emacs-skills;
    };
    lspServers = {
      python = {
        package = pkgs.basedpyright;
        args = [
          "--stdio"
        ];
        command = "basedpyright-langserver";
        extensionToLanguage = {
          ".py" = "python";
        };
      };
      go = {
        package = pkgs.gopls;
        args = [ "serve" ];
        command = "gopls";
        extensionToLanguage = {
          ".go" = "go";
        };
      };
      rust = {
        package = pkgs.rust-analyzer;
        command = "rust-analyzer";
        extensionToLanguage = {
          ".rs" = "rust";
        };
      };
      cxx = {
        package = pkgs.clang-tools;
        args = [ "--stdio" ];
        command = "clangd";
        extensionToLanguage = {
          ".c" = "c";
          ".h" = "c";
          ".hpp" = "c++";
          ".cpp" = "c++";
          ".cxx" = "c++";
          ".hxx" = "c++";
          ".cc" = "c++";
        };
      };
      zig = {
        package = pkgs.zls;
        command = "zls";
        extensionToLanguage = {
          ".zig" = "zig";
        };
      };
      typst = {
        package = pkgs.tinymist;
        command = "tinymist";
        extensionToLanguage = {
          ".typ" = "typst";
        };
      };
      nix = {
        package = pkgs.nixd;
        command = "nixd";
        extensionToLanguage = {
          ".nix" = "nix";
        };
      };
    };
    settings = {
      hooks = {
        SessionStart = [
          {
            matcher = "startup";
            hooks = [
              {
                command = "echo 'caveman mode'";
                type = "command";
              }
            ];
          }
        ];
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

    custom-instructions = builtins.readFile ./CLAUDE.md;

    # hack to workaround this option requiring an overly restrictive filesystem.path type
    skills =
      let
        skillsDir = "${
          pkgs.symlinkJoin {
            name = "codex-plugins";
            paths = [
              caveman
              emacs-skills
            ];
          }
        }/skills";
      in
      lib.mapAttrs (name: _: builtins.readFile (skillsDir + "/${name}/SKILL.md")) (
        builtins.readDir skillsDir
      );

    rules = {
      # deny
      destructive = ''prefix_rule(pattern=[["rm", "dd", "mkfs", "shutdown", "reboot"]], decision="forbidden")'';
      network = ''prefix_rule(pattern=[["curl", "ssh", "nc"]], decision="forbidden")'';
      sudo = ''prefix_rule(pattern=[["sudo", "su"]], decision="forbidden")'';
      # prompt
      emacs = ''prefix_rule(pattern=[["emacs", "emacsclient"]], decision="prompt")'';
      python = ''prefix_rule(pattern=[["python", "python3"]], decision="prompt")'';
      zig-prompt = ''prefix_rule(pattern=["zig", ["run", "test"]], decision="prompt")'';
      # allow
      zig-allow = ''prefix_rule(pattern=["zig", ["build-exe", "build", "cc", "fmt"]], decision="allow")'';
      nix = ''prefix_rule(pattern=["nix", ["develop", "shell", "build", "log", "fmt"]], decision="allow", match=["nix shell nixpkgs#hello", "nix build .#", "/nix/store/...-wine-wow64-staging-11.1.drv"], not_match=["nix develop nixpkgs#hello --command 'rm -rf /'", "nix shell .# -c 'python3 -c 'print(\"pwned\")'", "nix run nixpkgs#curl"])'';
      git = ''prefix_rule(pattern=["git", ["status", "log", "diff", "show"]], decision="allow")'';
      read = ''prefix_rule(pattern=[["cat", "ls", "grep", "rg", "fd"]], decision="allow", not_match=["cat ~/.ssh/id_ed25519", "rg '.*' ~/.gnupg/**", "ls ~/Mail", "grep '.*' ~/Library/**"])'';
    };
    settings = {
      sandbox_mode = "workspace-write";
      approval_policy = "untrusted";

      model_reasoning_summary = "detailed";
      hide_agent_reasoning = false;
      show_raw_agent_reasoning = true;

      features = {
        codex_hooks = true;
      };

      analytics.enabled = false;
      feedback.enabled = false;
      # history.persistence = "none"; # agent-shell does not support resuming from transcript
    };
  };

  programs.emacs.extraPackages =
    epkgs:
    (with epkgs; [
      gptel
      gptel-agent
      agent-shell

      pkgs.claude-agent-acp
      pkgs.codex-acp
      (pkgs.callPackage ./pi-coding-agent.nix { })
      (pkgs.callPackage ./pi-acp.nix { })
    ]);

  home.file.".pi/agent/models.json".text = builtins.toJSON {
    providers."llama-cpp" = {
      baseUrl = "http://vermillion:16111/v1";
      api = "openai-completions";
      apiKey = "none";
      models = [
        { id = "Qwen3.6-35B-A3B"; }
        { id = "Qwen3.5-9B"; }
      ];
    };
  };
  home.file.".pi/agent/settings.json".text = builtins.toJSON {
    compaction.enabled = true;
    defaultProvider = "llama-cpp";
    defaultModel = "Qwen3.6-35B-A3B";
  };
  home.file.".pi/agent/extensions/sandbox.json".text = builtins.toJSON {
    enabled = true;
    network = {
      allowedDomains = [ ];
    };
    filesystem = {
      denyRead = [
        "~/Library"
        "~/Mail"
        "~/Personal/Finance"
        "~/Personal/paperwork"
        "~/.ssh"
        "~/.gnupg"
        "~/.password-store"
        "~/.restic"
      ];
    };
  };

  home.file.".pi/agent/extensions/sandbox" = {
    recursive = true;
    source = pkgs.buildNpmPackage {
      name = "pi-extension-sandbox";
      src = pkgs.fetchFromGitHub {
        owner = "badlogic";
        repo = "pi-mono";
        tag = "v0.67.68";
        hash = "sha256-JNeLyRV62nI0QBcZEjb0/xfmD+SUBKYYQ4BhGrfzbGI=";
        rootDir = "packages/coding-agent/examples/extensions/sandbox";
      };

      npmDepsHash = "sha256-eJbT63DS557JrRE/dLLVITtZIHYsCxlowRJHIkSGKTc=";

      postInstall = ''
        mv $out/lib/node_modules/pi-extension-sandbox _out
        rm -rf $out
        mv _out $out
      '';
    };
  };
}
