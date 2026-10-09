{ inputs, username, lib, pkgs, ... }:

{
  imports = [
    ../../darwin
    ../../darwin/headless.nix
    ../../darwin/tailscale.nix
    (import ../../darwin/remote-builder.nix "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPWbZKbs/e4yXYkXBpzwkRxYXOHDl3OHOjpMze0nw5O5 nixremote@diamond")
  ];

  networking.knownNetworkServices = [ "Ethernet" ];

  users = let
    default = name: {
      inherit name;
      home = "/Users/${name}";
      createHome = true;
      shell = pkgs.zsh;
    };
    users' = {
      "${username}" = {
        uid = 501;
        shell = pkgs.fish;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB1ej2V2ZEk8Ov54C/VqjfXFIM1hnFwsj6J0PDa6SeQK ghuebner@Peridot"
        ];
      };
      "quincy" = {
        uid = 502;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOVY5KiP8XkUU8rybBTNXEhwmDyDDe6Z3bZEKhAkFKSh KathySpitzer@MacBook-Pro-15.local"
        ];
      };
      "sruggerio" = {
        uid = 503;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMirOM34/c6bpCTa8GWAA2M623QP0kYNnH4JRo7udldE"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEHuQ28b8IAhFUA1bEIfjEvyIaoYJILvZVj6QjKTFc4Z"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOfJOfvvzU+yvipBSb/VE4Cvpz2m4tK2xlEstKemWR2g"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIT1rXz5BNggTC7gxZ/0ZHjtosaW0fYfm6Yqz0PtIj/w"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPuTZGemlptv4gCBnZEpQMjgWNN83IditOUn4hf3u96P"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID+YeKwyxzv1UuGzGjgI8szH9exgLDFUz/Jr+iJSYiYl"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINfb80DeTY3N67/RTWZ3LqctHLtJrdG+Aqjt92ZL1KcV"
        ];
      };
      "cchurchwell" = {
        uid = 505;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICpjzyHan4fXSPGv/hVPNvB5cz9QQDqXwB2VQPAWNWRj cameron@anon"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKhHZMelKxeQcVkrbbVwi9+7oxMHaqK/ujO63aRXhtyw cameron@anon"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBkHe7782D0jiVt9mOHzpQq0c9aWCJmzpzcMPuK/0txJ cameron@anon"
        ];
      };
    };
  in {
    knownUsers = builtins.attrNames users';
    users = builtins.listToAttrs (lib.imap (i: user: { name = user.name; value = { uid = users'."${username}".uid + i; } // (default user.name) // user.value; }) (lib.attrsToList users'));
    groups."ssh" = {};
    # extra setup required:
    # sudo dseditgroup -o edit -a ssh -t group com.apple.access_ssh
    # sudo dseditgroup -o edit -a ... -t user ssh
  };
  system.primaryUser = username;
  system.defaults.loginwindow.autoLoginUser = username; # necessary for LaunchAgents to work

  programs.fish.enable = true;
  programs.zsh.enable = true;

  services.openssh.enable = true;

  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
  system.stateVersion = 7;
}
