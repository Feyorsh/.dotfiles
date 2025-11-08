{ pkgs, lib, config, ... }:
{
  home.file.".nethackrc".source = ./nethackrc;

  home.packages = with pkgs; [
    (nethack.overrideAttrs(prev: {
      postPatch = (prev.postPatch or "") + ''
        sed -e 's,-DNOMAIL ,,' \
            -e 's,/usr/bin/true,${coreutils}/bin/true,g' \
            -i sys/unix/hints/macosx10.14
      '';
    }))

    (pkgs.writeShellScriptBin "nh-open-mu4e" ''
      ${config.home.profileDirectory}/bin/emacsclient -n --eval "(progn (require 'mu4e) (mu4e-context-switch nil \"Personal\") (mu4e-search-bookmark \"maildir:/personal/INBOX AND flag:unread\"))"
    '')
  ];

  launchd.agents.maildir2mbox = {
    enable = true;
    config = {
      Program = lib.getExe (pkgs.writeScriptBin "maildir2mbox" ''
        #!${pkgs.python3}/bin/python3
        import os
        import mailbox
        from datetime import datetime, timedelta
        import pathlib

        MAILDIR = os.path.expanduser("~${config.home.username}/Mail/personal/INBOX")
        MBOX = "/tmp/nh.mbox"

        maildir = mailbox.Maildir(MAILDIR)
        for msg in maildir:
            if datetime.fromtimestamp(msg.get_date()) > datetime.now() - timedelta(minutes=5):
                pathlib.Path(MBOX).touch()
                break
        maildir.close()
      '');
      StartInterval = 5 * 60;
      StandardOutPath = "/tmp/nh_mail.out.log";
      StandardErrorPath = "/tmp/nh_mail.err.log";
      RunAtLoad = true;
    };
  };


  # programs.emacs.extraPackages = epkgs: (with epkgs; [ (pkgs.callPackage ./package.nix { inherit trivialBuild; }) ]);
}
