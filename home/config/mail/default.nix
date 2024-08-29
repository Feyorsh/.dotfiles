{ pkgs, lib, ... }: with pkgs;
let
  mutt_oauth2 = stdenv.mkDerivation rec {
      pname = "mutt_oauth2";
      version = "2020-08-07";

      src = fetchurl {
        url = "https://gitlab.com/muttmua/mutt/-/raw/master/contrib/mutt_oauth2.py?inline=false";
        sha256 = "sha256-R+sLNQ+NMZ70KQOX4RzWVMcOW/yJuUX6G9i3rG7lCe0=";
      };
      dontUnpack = true;

      buildInputs = [ python3 gnupg pass ];

      # from thunderbird, see
      # https://blog.thunderbird.net/2023/01/important-message-for-microsoft-office-365-enterprise-users/
      msft_client_id = "9e5f94bc-e8a4-4e73-b8be-63364c29d753"; 
      goog_client_id = "";

      subs = writeScript "mutt_sed" ''
        #!${pkgs.python3}/bin/python3
        import sys
        import itertools
        
        client_id = {
            "google": "${goog_client_id}",
            "microsoft": "${msft_client_id}",
                                                                   }
        
        seen = None
        out = []
        with open(sys.argv[1], 'r') as f:
            lines = f.readlines().__iter__()
            for l in lines:
                if "'client_id':" in l and seen:
                    l = l.replace("'''", f"'{client_id[seen]}'")
                    seen = None
                elif (g:="YOUR_GPG_IDENTITY") in l:
                    l = l.replace(g, "george@feyor.sh")
                elif (t := next((k for k in client_id.keys() if k in l), None)):
                    seen = t
                out.append(l)
        with open(sys.argv[2], 'w') as f:
          f.writelines(out)
      '';
      postPatch = "$subs $src ${pname}.py";

      installPhase = "install -m755 -D ${pname}.py $out/bin/${pname}.py";
    };
in {
  home.packages = [
    mu
    (isync.override { withCyrusSaslXoauth2 = true; })
    msmtp
    mutt_oauth2
  ];

  programs.emacs.extraPackages = epkgs: (with epkgs; [
    mu4e
    org-msg
  ]);
}
