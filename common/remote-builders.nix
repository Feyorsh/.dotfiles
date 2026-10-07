currentHost:
let
  nixos = {
    protocol = "ssh-ng";
    sshUser = "nixremote";
    sshKey = "/home/nixremote/.ssh/id_ed25519";
    supportedFeatures = [
      "kvm"
      "big-parallel"
      "benchmark"
    ];
  };
  darwin = {
    inherit (nixos)
      protocol
      sshUser
      sshKey
    ;
    supportedFeatures = [
      "apple-virt"
      "big-parallel"
      "benchmark"
    ];
    systems = [ "aarch64-darwin" ];
  };
  machines = builtins.filter (m: m.hostName != currentHost)
    [
      {
        inherit (nixos)
          protocol
          sshUser
          sshKey
          supportedFeatures
        ;
        hostName = "emerald";
        systems = [ "x86_64-linux" ];
        publicKey = "LhXXSgNg+TeXbAvO348YuoRzQRStC84kAHA0LWBDzns=";
      }
      {
        inherit (nixos)
          protocol
          sshUser
          sshKey
          supportedFeatures
        ;
        hostName = "vermillion";
        systems = [ "x86_64-linux" ];
        publicKey = "LhXXSgNg+TeXbAvO348YuoRzQRStC84kAHA0LWBDzns=";
      }
      {
        inherit (darwin)
          protocol
          sshUser
          sshKey
          supportedFeatures
          systems
        ;
        hostName = "diamond";
        # publicKey = "LhXXSgNg+TeXbAvO348YuoRzQRStC84kAHA0LWBDzns=";
      }
    ];
in
{
  trusted-public-keys = map (m: "${m.hostName}:${m.publicKey}") (builtins.filter (m: m ? publicKey) machines);
  trusted-substituters = map (m: "${m.protocol}://${m.hostName}") machines;
  buildMachines = map (m: removeAttrs m [ "publicKey" ]) machines;
}
