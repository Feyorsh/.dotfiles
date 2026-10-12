{ config, lib, pkgs, ... }:
let
  inherit (pkgs) nethack;
  cfg = config.services.dgamelaunch;
in
{
  options = {
    services.dgamelaunch = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to enable a dgamelaunch game server.
        '';
      };

      package = lib.mkPackageOption (pkgs.extend (final: prev: {
        # dgamelaunch = final.enableDebugging (final.callPackage ./default.nix {});
        dgamelaunch = final.callPackage ./default.nix {};
      })) "dgamelaunch" { };

      extraPackages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ nethack ];
        defaultText = lib.literalExpression "with pkgs; [ nethack ]";
        example = lib.literalExpression "with pkgs; [ nethack ]";
        description = ''
          List of extra packages to include in the chroot.
          Add any games or utilities to be managed by dgamelaunch here.
        '';
      };

      extraSetup = lib.mkOption {
        type = with lib.types; lines;
        default = let
          inherit (nethack) version;
          gameDir = "nh${builtins.replaceStrings [ "." ] [ "" ] version}";
          in ''
          mkdir {${gameDir},dgldir/inprogress/${gameDir}}
          ln -s ${nethack}/bin/nethack ${gameDir}/nethack

          sed -e 's#nh343#${gameDir}#I' \
              -e 's#NetHack 3.4.3#NetHack ${version}#' \
              -e 's#/nh367/var/#/${gameDir}/.config/nethack/var/#' \
              -e 's#%rinprogress-nh367/#%rinprogress/${gameDir}/#' \
              -e '/setenv "NETHACKOPTIONS"/a \ \ \ \ \ \ \ \ \ \ \ \ \ setenv "HOME" "/${gameDir}",' \
              -i dgamelaunch.conf
          sed -e 's/NetHack 3.4.3/NetHack ${version}/' -i dgldir/dgl_menu_main_user.txt
          tail -n +8 ${cfg.package}/share/examples/dgl-default-rcfile > dgl-default-rcfile.${gameDir}
        '';
        description = ''
          Any extra setup for the dgamelaunch chroot.
        '';
      };

      dataDir = lib.mkOption {
        type = lib.types.path;
        default = "/var/lib/dgamelaunch";
        description = ''
          Directory to store dgamelaunch sqlite DB and other state.
        '';
      };

      enableSSH = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to expose dgamelaunch via SSH.
        '';
      };

      telnetPort = lib.mkOption {
        type = lib.types.nullOr lib.types.port;
        default = null;
        description = ''
          Which port to use for the Telnet server.
          If set to null, no Telnet server will be started.
        '';
        example = 23;
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = "nethack";
        description = ''
          The dgamelaunch user.
        '';
        example = "games";
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = "nethack";
        description = ''
          The dgamelaunch group.
        '';
        example = "games";
      };
    };
  };

  config = {
    assertions = [
      {
        assertion = cfg.enableSSH -> config.services.openssh.enable;
        message = ''
          `services.dgamelaunch.enableSSH` requires that SSHD is enabled.
          Did you forget to set `services.openssh.enable`?
        '';
      }
    ];
  } // (let
    rootPaths =
      let
        contents = lib.concatStringsSep "\n" (cfg.extraPackages ++ [ cfg.package ]);
      in
        pkgs.writeText "dgamelaunch-chroot-string-contexts.txt" contents;

    chrootPaths =
      pkgs.runCommand "dgamelaunch-chroot-paths"
        {
          closureInfo = pkgs.closureInfo { inherit rootPaths; };
          excludedPath = rootPaths;
        }
        ''
          while read storePath; do
          if [ -L "$storePath" ]; then
              echo "-p BindReadOnlyPaths=$(readlink -e "$storePath"):$storePath \\"
          elif [ "$storePath" != "$excludedPath" ]; then
              echo "-p BindReadOnlyPaths=$storePath \\"
          fi
          done < "$closureInfo/store-paths" >> "$out"
        '';
    # don't use writeShellScriptBin to avoid IFD
    launcher = pkgs.writeTextFile rec {
      name = "dgamelaunch-launcher";
      executable = true;
      destination = "/bin/${name}";

      derivationArgs = { inherit chrootPaths; };

      text = ''
        /run/wrappers/bin/umount /run/dgamelaunch
        /run/current-system/systemd/bin/systemctl restart run-dgamelaunch.mount
        /run/current-system/systemd/bin/systemctl restart dgamelaunch-setup.service
        exec -a dgamelaunch /run/current-system/systemd/bin/systemd-run \
          -E DGLAUTH \
          -p RootDirectory=/run/dgamelaunch \
          $(cat "$chrootPaths")   -p MountAPIVFS=true \
          -p BindPaths=${cfg.dataDir}/dgldir/inprogress:/dgldir/inprogress \
          -p PrivatePIDs=true \
          -p PrivateTmp=true \
          --pty --pipe -q ${lib.getExe' cfg.package "dgamelaunch"}
      '';
      checkPhase = ''
        ${pkgs.stdenv.shellDryRun} "$target"
      '';
      meta.mainProgram = name;
    };
    shell = (pkgs.writeShellScriptBin "dgamelaunch-shell"
      ''
        exec /run/wrappers/bin/sudo DGLAUTH="''${DGLAUTH:-$USER}" ${lib.getExe launcher}
      '') // { shellPath = "/bin/dgamelaunch-shell"; };
  in
    lib.mkIf cfg.enable {
      services.openssh = lib.mkIf (cfg.enableSSH != null) {
        extraConfig = ''
          Match User ${cfg.user}
            AcceptEnv DGLAUTH
            PermitEmptyPasswords yes
            AllowAgentForwarding no
            AllowTcpForwarding no
            PubkeyAuthentication no
            PasswordAuthentication yes
            KbdInteractiveAuthentication yes
        '';
      };
      security.pam.services.sshd = lib.mkIf (cfg.enableSSH != null) {
        rules.auth = {
          dgamelaunch-guard = {
            enable = true;
            control = "[success=1 default=ignore]";
            modulePath = "${config.security.pam.package}/lib/security/pam_succeed_if.so";
            args = [ "user" "!=" cfg.user ];
            order = config.security.pam.services.sshd.rules.auth.dgamelaunch.order - 1;
          };
          dgamelaunch = {
            enable = true;
            control = "sufficient";
            modulePath = "${config.security.pam.package}/lib/security/pam_unix.so";
            args = [ "nullok" ];
            order = config.security.pam.services.sshd.rules.auth.deny.order - 10;
          };
        };
        rules.session.dgamelaunch = {
          enable = true;
          control = "[success=1 default=ignore]";
          modulePath = "${config.security.pam.package}/lib/security/pam_succeed_if.so";
          args = [ "user" "=" cfg.user ];
          order = config.security.pam.services.sshd.rules.session.env.order - 1;
        };
      };

      users.users.${cfg.user} = {
        description = "dgamelaunch user";
        password = "";
        isSystemUser = true;
        group = cfg.group;
        inherit shell;
      };
      users.groups.${cfg.group} = { };

      security.sudo.extraRules = lib.optionals (cfg.enableSSH != null || cfg.telnetPort != null) [{
        users = [ cfg.user ];
        commands = [ { command = lib.getExe launcher; options = [ "NOPASSWD" "SETENV" ]; } ];
      }];

      systemd.tmpfiles.settings.dgamelaunch = {
        "/run/dgamelaunch".d = {
          mode = "770";
          inherit (cfg) user group;
        };
      };

      systemd.mounts = let
        chroot = (pkgs.buildFHSEnv {
          name = "dgamelaunch-chroot";
          targetPkgs = pkgs: [ pkgs.sqlite cfg.package ];
        }).fhsenv;
      in
        [{
          type = "overlay";
          what = "overlay";
          where = "/run/dgamelaunch";
          options = "lowerdir=${chroot},upperdir=${cfg.dataDir},workdir=${cfg.dataDir}/../.dgamelaunch-workdir";
      }];

      systemd.services.dgamelaunch-setup = {
        script = ''
        mkdir -p ${cfg.dataDir}/{dgldir/userdata,mail}
        cd ${cfg.dataDir}

        ${lib.getExe pkgs.sqlite} dgldir/dgamelaunch.db "create table dglusers (id integer primary key, username text, email text, env text, password text, flags integer);"
        cp ${cfg.package}/share/examples/{dgamelaunch.conf,dgl-banner} .
        cp ${cfg.package}/share/examples/dgl_menu_main* dgldir/
        sed -e 's#chroot_path = "/opt/nethack/nethack.alt.org/"#chroot_path = "/"#' \
            -e 's#shed_uid = .*#shed_uid = '"$(id -u ${cfg.user} | tr -d '\n')"'#' \
            -e 's#shed_gid = .*#shed_gid = '"$(id -g ${cfg.group} | tr -d '\n')"'#' \
            -i dgamelaunch.conf

        ${cfg.extraSetup}

        chown -R ${cfg.user}:${cfg.group} ${cfg.dataDir}
        chmod -R 770 ${cfg.dataDir}
      '';
        unitConfig = {
          ConditionPathExists = "!${cfg.dataDir}";
        };
      };

      systemd.sockets."dgamelaunch-telnet" = lib.mkIf (cfg.telnetPort != null) {
        wantedBy = [ "sockets.target" ];
        socketConfig = {
          ListenStream = cfg.telnetPort;
          Accept = true;
        };
      };

      systemd.services."dgamelaunch-telnet@" = lib.mkIf (cfg.telnetPort != null) {
        serviceConfig = {
          ExecStart = "${pkgs.inetutils}/libexec/telnetd -E ${shell}";
          User = cfg.user;
          Group = cfg.group;
          StandardInput = "socket";
          StandardOutput = "socket";
        };
      };

      networking.firewall = lib.mkIf (cfg.telnetPort != null) {
        allowedTCPPorts = [ cfg.telnetPort ];
      };
    });
}
