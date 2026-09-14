{ pkgs, ... }: with pkgs;
let
  mutt_oauth2 = writers.writePython3Bin "mutt_oauth2.py" {
    libraries = [ gnupg ];
    flakeIgnore = [ "E501" "E731" "W504" ];
  } (builtins.readFile ./mutt_oauth2.py);
in {
  home.packages = [
    mu
    (isync.override { withCyrusSaslXoauth2 = true; })
    msmtp
    mutt_oauth2
    pass
  ];

  programs.git.settings.sendemail.sendmailCmd = lib.getExe pkgs.msmtp;

  programs.emacs.extraPackages = epkgs: (with epkgs; [
    mu4e
    org-msg

    (let withEmbark = true; in trivialBuild rec {
      pname = "consult-mu";
      version = "1.0-unstable-2025-08-01";
      src = fetchFromGitHub {
        owner = "armindarvish";
        repo = pname;
        rev = "4958fb651917b0f9f79f436f7a753263c8003537";
        hash = "sha256-cRFYTnfwWz4bxCirDHJ43Vw3eAYthJ5auRHLd+Cgo5c=";
      };
      postPatch = lib.optionalString (!withEmbark) ''
        rm extras/consult-mu-{compose,contacts}-embark.el
      '';
      packageRequires = [ consult mu4e ] ++ lib.optionals (withEmbark) [ embark ];
    })
  ]);
}
