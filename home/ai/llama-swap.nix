# nixos/modules/services/networking/llama-swap.nix lightly modified to use launchd instead of systemd
{ config, lib, pkgs, ... }:
let
  cfg = config.services.llama-swap;
  settingsFormat = pkgs.formats.yaml { };
  configFile = settingsFormat.generate "config.yaml" cfg.settings;
in
{
  options.services.llama-swap = {
    enable = lib.mkEnableOption "the llama-swap service";

    package = lib.mkPackageOption pkgs "llama-swap" {
      default = [ "llama-swap-minimal" ];
    };

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "localhost";
      example = "0.0.0.0";
      description = ''
        Address that llama-swap listens on.
      '';
    };

    port = lib.mkOption {
      default = 8080;
      example = 11343;
      type = lib.types.port;
      description = ''
        Port that llama-swap listens on.
      '';
    };

    settings = lib.mkOption {
      type = lib.types.submodule { freeformType = settingsFormat.type; };
      description = ''
        llama-swap configuration. Refer to the [llama-swap example configuration](https://github.com/mostlygeek/llama-swap/blob/main/config.example.yaml)
        for details on supported values.
      '';
      example = lib.literalExpression ''
        let
          llama-cpp = pkgs.llama-cpp.override { rocmSupport = true; };
          llama-server = lib.getExe' llama-cpp "llama-server";
        in
        {
          healthCheckTimeout = 60;
          models = {
            "some-model" = {
              cmd = "''${llama-server} --port ''${PORT} -m /var/lib/llama-cpp/models/some-model.gguf -ngl 0 --no-webui";
              aliases = [
                "the-best"
              ];
            };
            "other-model" = {
              proxy = "http://127.0.0.1:5555";
              cmd = "''${llama-server} --port 5555 -m /var/lib/llama-cpp/models/other-model.gguf -ngl 0 -c 4096 -np 4 --no-webui";
              concurrencyLimit = 4;
            };
          };
        };
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    launchd.agents."llama-cpp" = {
      enable = true;
      config = {
        ProgramArguments = [
          "${cfg.package}/bin/llama-swap"
          "--config"
          "${configFile}"
          "--listen"
          "${cfg.listenAddress}:${toString cfg.port}"
        ];
        RunAtLoad = true;
        KeepAlive = true;

        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/llama-cpp.log";
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/llama-cpp.log";
      };
    };
  };
}
