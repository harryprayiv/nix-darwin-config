{
  config,
  lib,
  pkgs,
  stdenv,
  inputs,
  ...
}: let
  securityPkgs = with pkgs; [
    pinentry
    # rage
    # keepassxc
    gnupg
    # ledger-live-desktop
    # bitwarden-cli
    # libgnome-keyring
  ];

  more = {
    programs.git = {
      signing = {
        # gpgPath = "${pkgs.gnupg}/bin/gpg2";
        key = "AAF9795E393B4DA0";
        signByDefault = true;
      };
      userEmail = "harryprayiv@gmail.com";
      userName = "harryprayiv";
    };

    programs.vscode.userSettings = {
      "git.autofetch" = true;
      "git.autoStash" = true;
      "git.signing.key" = "AAF9795E393B4DA0";
      "git.userEmail" = "harryprayiv@gmail.com";
      "git.userName" = "harryprayiv";
      "git.enableCommitSigning" = true;
      "github.copilot.enable" = {
        "*" = true;
        "plaintext" = true;
        "markdown" = false;
        "scminput" = false;
      };
      "editor.inlineSuggest.enabled" = true;
    };

    programs.gpg.enable = true;
    programs.ssh.enable = true;
  };
in
  {
    home.packages = securityPkgs;
    imports = [
      # ./yubikey
    ];
  }
  // more
