{
  config,
  lib,
  pkgs,
  ...
}:
#This is a hack that I've had to employ that gets everything loaded properly in direnv
let
  alacritty = "${pkgs.alacritty}/bin/alacritty";
  bash = "${pkgs.bash}/bin/bash";
  #hls = "${pkgs.haskellPackages.haskell-language-server}/bin/haskell-language-server";
  hlint = "${pkgs.hlint}/bin/hlint}";
in {
  ## confidential info in secrets now

  programs.vscode = {
    enable = true;
    # haskell.enable = true;
    # haskell.hie.enable = true;
    # haskell.hie.executablePath = -true;
    package = pkgs.vscodium.overrideAttrs (old: {
      buildInputs = old.buildInputs or [] ++ [pkgs.makeWrapper];
      postInstall =
        old.postInstall
        or []
        ++ [
          ''
            wrapProgram $out/bin/codium --add-flags '--force-disable-user-env'
          ''
        ];
    });
    enableUpdateCheck = false;
    extensions = let
      loadAfter = deps: pkg:
        pkg.overrideAttrs (old: {
          nativeBuildInputs = old.nativeBuildInputs or [] ++ [pkgs.jq pkgs.moreutils];

          preInstall =
            old.preInstall
            or []
            ++ [
              ''
                jq '.extensionDependencies |= . + $deps' \
                  --argjson deps ${pkgs.lib.escapeShellArg (builtins.toJSON deps)} \
                  package.json | sponge package.json
              ''
            ];
        });
    in
      pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          publisher = "cab404";
          name = "vscode-direnv";
          version = "1.0.0";
          sha256 = "sha256-+nLH+T9v6TQCqKZw6HPN/ZevQ65FVm2SAo2V9RecM3Y=";
        }
      ]
      ++ map (loadAfter ["cab404.vscode-direnv"]) (
        with pkgs.vscode-extensions;
          [
            mkhl.direnv
            bbenoist.nix
            haskell.haskell
            justusadam.language-haskell
            arrterian.nix-env-selector
            jnoortheen.nix-ide
            gruntfuggly.todo-tree
            kamadorueda.alejandra
            github.copilot
            # gattytto.phoityne-vscode
            # vscode-org-mode.org-mode
          ]
          ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
            # {
            #   publisher = "mrded";
            #   name = "railscasts";
            #   version = "0.0.4";
            #   sha256 = "sha256-vjfoeRW+rmYlzSuEbYJqg41r03zSfbfuNCfAhHYyjDc=";
            # }

            # {
            #   name = "copilot";
            #   publisher = "GitHub";
            #   version = "1.46.6822";
            #   sha256 = "sha256-L71mC0190ZubqNVliu7es4SDsBTGVokePpcNupABI8Q=";
            # }
          ]
      );
    userSettings = {
      "editor.fontSize" = 13;
      "update.mode" = "none";
      "window.zoomLevel" = "-2";
      "terminal.explorerKind" = "external";
      "terminal.external.linuxExec" = "${alacritty}";
      "terminal.integrated.defaultProfile.linux" = "bash";
      "terminal.integrated.copyOnSelection" = true;
      "nix.enableLanguageServer" = true;
      "explorer.confirmDelete" = false;
      "explorer.confirmDragAndDrop" = false;
      "editor.minimap.enabled" = false;
      "diffEditor.ignoreTrimWhitespace" = false;
      "window.autoDetectColorScheme" = false;
      # "workbench.statusBar.visible" = false;
      "[haskell]" = {
        "editor.defaultFormatter" = "haskell.haskell";
      };
      "workbench.colorCustomizations" = {
        #ugly right now
        "statusBar.background" = "#282a33";
        "statusBar.noFolderBackground" = "#32343d";
        "statusBar.debuggingBackground" = "#32343d";
        "editor.background" = "#32343d";
        "statusBarItem.remoteBackground" = "#32343d";
        "mergeEditor.change.background" = "#627A92";
        "mergeEditor.change.word.background" = "#282a33";
        "tab.inactiveBackground" = "#282a33";
        "sideBar.background" = "#282a33";
        "sideBar.dropBackground" = "#282a33";
        "input.background" = "#282a33";
        "banner.background" = "#282a33";
        "minimap.background" = "#282a33";
        "menu.background" = "#282a33";
        "menu.selectionBackground" = "#282a33";
        "icon.foreground" = "#FFFFFF";
        "statusBarItem.prominentBackground" = "#282a33";
      };
      # "haskell.hlint.ignore" = "[]";
    };
  };

  home.file.".vscode/argv.json" = {
    force = true;
    text = ''
      {
      	"disable-hardware-acceleration": true,
      	"enable-crash-reporter": true,
      	// Unique id used for correlating crash reports sent from this instance.
      	// Do not edit this value.
        "crash-reporter-id": "4e77d7bd-2f26-4723-9757-4f86cefd7010"
        "password-store": "gnome"
      }
    '';
  };
}
