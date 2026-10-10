{ lib, pkgs, ... }:

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
        models = {
          "qwen3.8-flash-next" = {
            cmd = mtplxCmd "qwen3.8-flash-next" "Youssofal/Qwen3.8-Flash-Next-MTPLX-Optimized-Speed";
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
            cmd = mtplxCmd "qwen3.8-27b" "Youssofal/Qwen3.8-27B-MTPLX-Optimized-Speed";
          };
        };
      in models;
    };
  };

  home.stateVersion = "26.05";
}
