currentHost:
let
  nixos = {
    protocol = "ssh-ng";
    sshUser = "nixremote";
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
          supportedFeatures
        ;
        hostName = "emerald";
        systems = [ "x86_64-linux" ];
        publicKey = "NjBGqf7fZVcS8y1RQ2ZcpzVDhaeDlH++0vOaaBI3z74=";
      }
      {
        inherit (nixos)
          protocol
          sshUser
          supportedFeatures
        ;
        hostName = "vermillion";
        systems = [ "x86_64-linux" ];
        publicKey = "W9yxGAD5f6BLrcpHZEXmRsDuQDNdpCHQJCnGuE7qAmI=";
      }
      {
        inherit (darwin)
          protocol
          sshUser
          supportedFeatures
          systems
        ;
        hostName = "diamond";
        publicKey = "V4PDpxXfGRNH8i7ALZTvAt97e0kZ/wAtz0SqEkrxHj0=";
      }
    ];
in
{
  trusted-public-keys = map (m: "${m.hostName}:${m.publicKey}") (builtins.filter (m: m ? publicKey) machines);
  substituters = map (m: "${m.protocol}://${m.hostName}") machines;
  buildMachines = map (m: removeAttrs m [ "publicKey" ]) machines;
}
