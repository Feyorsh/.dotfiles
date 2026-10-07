{ config, pkgs, lib, ... }:
let
  caveman = pkgs.fetchFromGitHub {
    owner = "JuliusBrussee";
    repo = "caveman";
    tag = "v2.7.0";
    hash = "sha256-dsGzPscjy7FfaovfYML2q+RmuBJwwEJ9sjeHi+Niv6Y=";
  };
  emacs-skills = pkgs.fetchFromGitHub {
    owner = "xenodium";
    repo = "emacs-skills";
    rev = "a158238bd630ebe68f57fb9caf99e984e757ca4f";
    hash = "sha256-ZWikhVPlgTw5TqgXU8pCZSRPvnSAxHCqnqgiZvAuV+8=";
  };
in
{
  programs.codex = {
    enable = true;

    context = builtins.readFile ./AGENTS.md;

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
      in lib.pipe (builtins.readDir skillsDir) [
        (lib.filterAttrs (name: fileType: fileType == "directory" && builtins.pathExists (skillsDir + "/${name}/SKILL.md")))
        (lib.mapAttrs (name: _: builtins.readFile (skillsDir + "/${name}/SKILL.md")))
      ];

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
      sandbox_mode = "read-only";
      approval_policy = "on-request";
      approvals_reviewer = "auto_review";

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

  programs.pi-coding-agent = {
    enable = true;
    context = ./AGENTS.md;
    extraPackages = with pkgs; [ nodejs bun ];
    configDir = "${config.xdg.configHome}/pi/agent";

    models = {
      providers = {
        mtplx = {
          api = "openai-completions";
          baseUrl = "http://diamond:8000/v1";
          models = [
            {
              id = "qwen3.8-flash";
            }
          ];
        };
      };
    };

    settings = {
      defaultModel = "qwen3.8-flash";
      defaultProvider = "mtplx";
      defaultThinkingLevel = "medium";

      compaction = {
        enabled = true;
        keepRecentTokens = 20000;
        reserveTokens = 16384;
      };
    };
  };
  home.file."${config.xdg.configHome}/pi/agent/skills".source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/codex/skills";

  programs.emacs.extraPackages = epkgs: (with epkgs; [
    gptel
    gptel-agent
    agent-shell agent-shell-math-renderer

    pkgs.codex-acp
    (pkgs.callPackage ./pi-acp.nix { })
  ]);
}
