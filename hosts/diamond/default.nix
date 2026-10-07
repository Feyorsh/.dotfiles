{ inputs, username, pkgs, ... }:

{
  imports = [
    ../../darwin
    ../../darwin/tailscale.nix
  ];

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
      "nixremote" = {
        isHidden = true;
        shell = null;
        home = "/Users/.nixremote";
        createHome = false;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICpjzyHan4fXSPGv/hVPNvB5cz9QQDqXwB2VQPAWNWRj cameron@anon"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKhHZMelKxeQcVkrbbVwi9+7oxMHaqK/ujO63aRXhtyw cameron@anon"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBkHe7782D0jiVt9mOHzpQq0c9aWCJmzpzcMPuK/0txJ cameron@anon"
        ];
      };
      "quincy" = {
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOVY5KiP8XkUU8rybBTNXEhwmDyDDe6Z3bZEKhAkFKSh KathySpitzer@MacBook-Pro-15.local"
        ];
      };
      "sruggerio" = {
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
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICpjzyHan4fXSPGv/hVPNvB5cz9QQDqXwB2VQPAWNWRj cameron@anon"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKhHZMelKxeQcVkrbbVwi9+7oxMHaqK/ujO63aRXhtyw cameron@anon"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBkHe7782D0jiVt9mOHzpQq0c9aWCJmzpzcMPuK/0txJ cameron@anon"
        ];
      };
    };
  in {
    knownUsers = builtins.attrNames users';
    users = builtins.mapAttrs (user: settings: (default user) // settings) users';
  };
  system.primaryUser = username;

  nix.settings = {
    trusted-users = [ "nixremote" ];
  };

  programs.fish.enable = true;
  programs.zsh.enable = true;

  services.openssh.enable = true;

  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
  system.stateVersion = 7;
}
