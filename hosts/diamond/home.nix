{ lib, pkgs, config, ... }:

{
  imports = [
    ../../home
    ../../home/editor/remote.nix
    ../../home/ai/llama-swap.nix
  ];

  services.llama-swap = {
    enable = true;
    package = with pkgs; symlinkJoin {
      name = "llama-swap";
      paths = [ llama-swap-minimal ];
      nativeBuildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/llama-swap --run 'export LLAMA_SWAP_KEY="$(cat ~/.llama-swap/key)"'
      '';
    };

    listenAddress = "0.0.0.0";
    port = 4141;

    settings = {
      apiKeys = [ "\${env.LLAMA_SWAP_KEY}" ];

      globalTtl = 60 * 30;
      globalConcurrencyLimit = 10;

      sendLoadingState = true;
      includeAliasesInList = true;

      models = let
        mtplxCmd = id: modelName: "${lib.getExe' pkgs.uv "uvx"} mtplx serve ${
          lib.escapeShellArgs [
            "--model" modelName
            "--host" "127.0.0.1"
            "--port" "\${PORT}"
            "--no-auth"
            "--tool-prompt-mode" "native"
            "--model-id" id
          ]
        }";
        mtplxEffort = builtins.listToAttrs (
          map
            (effort: {
              name = "\${MODEL_ID}:${effort}";
              value = { "reasoning_effort?" = effort; };
            })
            [ "medium" "xhigh" ]
        );
        llama-cpp = pkgs.llama-cpp.overrideAttrs (prev: rec {
          version = "0.7.0";
          patches = [];
          src = pkgs.fetchFromGitHub {
            owner = "ggml-org";
            repo = "llama.cpp";
            tag = "v${version}";
            hash = "sha256-pEDYgI3AMTU+cekvRX7NNt5wddznydQSNuerswvEpsA=";
          };
          npmDepsHash = "sha256-hqYzdp1FwPhYkBP278fQXgY9NCKB6Q3P6Gko7BfP0m0=";
          cmakeFlags = (prev.cmakeFlags or []) ++ [
            (lib.cmakeFeature "LLAMA_BUILD_NUMBER" "11669")
            (lib.cmakeFeature "LLAMA_BUILD_COMMIT" "620d222")
          ];
        });
        models = {
          "qwen3.8-flash-next" = {
            cmd = mtplxCmd "qwen3.8-flash-next" "UkisAI/Swift1.5-Qwen3.8-Flash-Next-MTPLX-Optimized-Speed";
            setParamsByID = mtplxEffort // { "\${MODEL_ID}" = mtplxEffort."\${MODEL_ID}:xhigh"; };
            metadata.port = "\${PORT}";
            capabilities = {
              "in" = [ "text" "image" ];
              out = [ "text" "image" ];
              tools = true;
            };
          };
          "qwen3.8-27b" = {
            inherit (models."qwen3.8-flash-next")
              setParamsByID
              metadata
              capabilities
            ;
            cmd = mtplxCmd "qwen3.8-27b" "UkisAI/Swift1.5-Qwen3.8-27b-MTPLX-Optimized-Speed";
          };
          "glm5.3-flash" = {
            cmd = "${lib.getExe' llama-cpp "llama-server"} ${
              lib.escapeShellArgs [
                "--host" "127.0.0.1"
                "--port" "\${PORT}"
                "--no-ui"
                "-hf" "unsloth/GLM-5.3-Flash-GGUF:UD-IQ2_XXS"
                "--alias" "glm5.3-flash"
                "-ngl" "99"
                "-c" "32768"
                "-b" "2048" "-ub" "2048"
                "-fa" "on"
                "--cache-type-k" "q8_0" "--cache-type-v" "q8_0"
                "--spec-type" "draft-mtp"
                "--spec-draft-n-max" "2" "--spec-draft-n-min" "1" "--spec-draft-p-min" "0.75"
                "--temp" "1.0" "--top-p" "0.95"
                "--parallel" "1"
              ]
            }";
            aliases = [ "glm5.3-flash" ];
          };
        };
      in models;
    };
  };

  home.stateVersion = "26.05";
}
