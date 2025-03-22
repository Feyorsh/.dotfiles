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
      ];
      postBuild = ''
        makeDarwinBundlePhase
        rm "$out/Applications/Firefox (School).app/Contents/Resources/firefox.icns"
        cp ${../../assets/icons/firefox.icns} "$out/Applications/Firefox (School).app/Contents/Resources/firefox.icns"

        mkdir -p $out/bin
        {
          echo "#! ${pkgs.runtimeShell} -e"
          echo "open -a "$out/Applications/Firefox.app" --args -p School" '"$@"'
        } > "$out/bin/firefox-profile-wrapper"
        chmod +x "$out/bin/firefox-profile-wrapper"
      '';
  };
in
{
  home.packages = [ firefoxWrapped ];
}
