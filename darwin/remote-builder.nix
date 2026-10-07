# additional setup:
#
# cd ~nixremote && nix-store --generate-binary-cache-key nixremote cache-priv-key.pem cache-pub-key.pem
#
# You must also copy the private keys (used for SSHing into the builders) to /root/.ssh/builders on all other machines
key:
let
  user = "nixremote";
in
{
  nix = {
    settings.trusted-users = [ user ];
    extraOptions = ''
      secret-key-files = /Users/.${user}/cache-priv-key.pem
    '';
  };

  users.users."${user}" = {
    isHidden = true;
    shell = null;
    home = "/Users/.${user}";
    createHome = false;
    openssh.authorizedKeys.keys = [ key ];
  };
}
