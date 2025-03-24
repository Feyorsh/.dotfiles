{ pkgs, lib, ... }:
let
  firefoxWrapped = pkgs.symlinkJoin {
      name = "firefox";
      paths = [ pkgs.firefox-bin ];
      nativeBuildInputs = [
        (pkgs.substitute {
          src = (pkgs.makeDarwinBundle {
            name = "Firefox (School)";
            exec = "firefox-profile-wrapper";
            icon = "firefox.icns";
          });
          substitutions = [
            "--replace-fail"
            ''"Firefox (School)" "firefox-profile-wrapper"''
            ''"Firefox (School)" "firefox-profile-wrapper" "firefox" "${lib.boolToString true}"''
          ];
        })
        pkgs.makeWrapper
      ];
      postBuild = ''
        makeDarwinBundlePhase
        rm "$out/Applications/Firefox (School).app/Contents/Resources/firefox.icns"
        cp ${../../../../assets/icons/firefox.icns} "$out/Applications/Firefox (School).app/Contents/Resources/firefox.icns"

        mkdir -p $out/bin

        makeWrapper $out/bin/firefox-profile-wrapper $out/Applications/Firefox.app/Contents/MacOS/firefox --add-flags '-p School'
        # {
        #   echo "#! ${pkgs.runtimeShell} -e"
        #   echo "open -a "$out/Applications/Firefox.app" --args -p School" '"$@"'
        #   echo "open -a "$out/Applications/Firefox.app" --args -p School" '"$@"'
        # } > "$out/bin/firefox-profile-wrapper"
        # chmod +x "$out/bin/firefox-profile-wrapper"
      '';
  };
in
{
  home.packages = [
    firefoxWrapped
    pkgs.tridactyl-native
  ];

  xdg.configFile."tridactyl/tridactylrc".source = ./tridactylrc;
}
