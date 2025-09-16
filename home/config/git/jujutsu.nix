{ pkgs, lib, ... }:
let
  emacsDiffScript = pkgs.writeShellScriptBin "emacs-ediff" ''
    set -euxo pipefail
    if [ "$#" -gt 3 ]; then
        emacsclient --eval "(ediff-merge-files-with-ancestor \"$1\" \"$2\" \"$3\" nil \"$4\")"
    else
        emacsclient --eval "(ediff-merge-directories \"$1\" \"$2\" nil \"$3\")"
    fi
  '';
in
{
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "George Huebner";
        email = "george@feyor.sh";
      };
      template-aliases = {
        "format_short_signature(signature)" = "signature.name()";
        "format_timestamp(timestamp)" = "separate(' ', timestamp.format('%a %e %b %Y %T'), surround('(', ')', timestamp.ago()))";
      };
      templates = {
        draft_commit_description = ''
           concat(
             coalesce(description, builtin_draft_commit_description, "\n"),
             surround(
               "\nJJ: This commit contains the following changes:\n", "",
               indent("JJ:     ", diff.stat(72)),
             ),
             "\nJJ: ignore-rest\n",
             diff.git(),
           )
        '';
        git_push_bookmark = ''"fysh/push-" ++ change_id.short()'';
      };
      signing = {
        behaviour = "own";
        backend = "ssh";
        key = "~/.ssh/id_ed25519.pub";
      };
      "--scope" = [{
        "--when" = {
          repositories = ["~/School"];
        };
        user = {
          email = "georgeh3@illinois.edu";
        };
      }];
      ui = {
        default-command = "status";
        movement.edit = true;
        log-synthetic-elided-nodes = true;
        merge-editor = "ediff";
        # diff-editor = "ediff";
        diff-formatter = ["difft" "--color=always" "$left" "$right"];
      };
      git = {
        write-change-id-header = true;
        fetch = ["upstream" "origin"];
        private-commits = "description(glob:'private:*')";
        sign-on-push = true;
      };
      merge-tools.ediff = {
        program = lib.getExe emacsDiffScript;
        merge-args = ["$left" "$right" "$base" "$output"];
        edit-args = ["$left" "$right" "$output"];
      };
      core = {
        fsmonitor = "watchman";
        watchman.register-snapshot-trigger = true;
      };
      colors = {
        "empty" = "bright black";
        "empty description placeholder" = "bright white";
        "description placeholder" = "bright yellow";

        "working_copy empty" = "bright black";
        "working_copy empty description placeholder" = "bright white";
        "working_copy description placeholder" = "yellow";

        "bookmark" = "green";
        "bookmarks" = "green";
        "local_bookmarks" = "green";
        "remote_bookmarks" = "green";
        "git_refs" = { fg = "green"; underline = true; };
        "git_head" = { fg = "green"; underline = true; };

        "author" = "bright blue";
        "working_copy author" = "bright blue";
      };
    };
  };

  home.packages = with pkgs; [ watchman ];
  programs.emacs.extraPackages = epkgs: (with epkgs; [ (vc-jj.overrideAttrs (_: rec {
    src = pkgs.fetchurl {
      url = "https://elpa.gnu.org/packages/vc-jj-${version}.tar";
      hash = "sha256-Pnw7F9N4wyDsp1/M+SPa9JEzD+L2Ko9Dt53H5X0BmvM=";
    };
    version = "0.4";
  })) ]);

  programs.fish.functions = {
    fish_jj_prompt = {
      description = "Write out the jj prompt";
      body = '';
        if not command -sq jj
            return 1
        end

        if not jj root --quiet &>/dev/null
            return 1
        end

        # Generate prompt
        jj log --ignore-working-copy --no-graph --color always -r @ -T '
            " " ++ separate(" ", concat(if(conflict, label("conflict", "!")), if(hidden, label("hidden", "◌")), if(divergent, label("divergent", "⑂")), if(empty, label("empty", "∅"))), change_id.shortest(3), commit_id.shortest(3), surround("(", ")", bookmarks.join(" ")), label("working_copies", surround("\"", "\"",
                         if(description.first_line().substr(0, 24).starts_with(description.first_line()),
                            description.first_line().substr(0, 24),
                            description.first_line().substr(0, 23) ++ "…"))))
        ' 2>/dev/null
      '';
    };
    "_pure_prompt_git" = ''
      set ABORT_FEATURE 2

      if type -q fish_jj_prompt && fish_jj_prompt
          return
      end

      if set --query pure_enable_git; and test "$pure_enable_git" != true
          return
      end

      if not type -q --no-functions git  # skip git-related features when `git` is not available
          return $ABORT_FEATURE
      end

      set --local is_git_repository (command git rev-parse --is-inside-work-tree 2>/dev/null)

      if test -n "$is_git_repository"
          set --local git_prompt (_pure_prompt_git_branch)(_pure_prompt_git_dirty)(_pure_prompt_git_stash)
          set --local git_pending_commits (_pure_prompt_git_pending_commits)

          if test (_pure_string_width $git_pending_commits) -ne 0
              set --append git_prompt $git_pending_commits
          end

          echo $git_prompt
      end
      '';
  };
}
