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
  fourmolu = "${pkgs.haskellPackages.hls-fourmolu-plugin}/bin/hls-fourmolu-plugin";
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
          # Name: direnv
          # Id: cab404.vscode-direnv
          # Description: Automatically detect and load .envrc when opening VS Code
          # Version: 1.0.0
          # Publisher: cab404
          # VS Marketplace Link: https://open-vsx.org/vscode/item?itemName=cab404.vscode-direnv
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
          ]
          ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
            # {
            #   publisher = "gattytto";
            #   name = "Haskell GHCi Debug Adapter Phoityne";
            #   version = "0.0.29";
            #   sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
            #   # gattytto.phoityne-vscode
            #   # Name: Haskell GHCi Debug Adapter Phoityne
            #   # Id: gattytto.phoityne-vscode
            #   # Description: Haskell GHCi Debug Adapter Phoityne for Visual Studio Code.
            #   # Version: 0.0.29
            #   # Publisher: gattytto
            #   # VS Marketplace Link: https://open-vsx.org/vscode/item?itemName=gattytto.phoityne-vscode
            # }
            {
              publisher = "nwolverson";
              name = "language-purescript";
              version = "0.2.8";
              sha256 = "sha256-2uOwCHvnlQQM8s8n7dtvIaMgpW8ROeoUraM02rncH9o=";
            }
            {
              publisher = "nwolverson";
              name = "ide-purescript";
              version = "0.26.2";
              sha256 = "sha256-72DRp+XLPlOowkRqyCWAeU/MNUr01m39IkCHCm5zpVc=";
            }
            # {
            #   publisher = "mrded";
            #   name = "railscasts";
            #   version = "0.0.4";
            #   sha256 = "sha256-vjfoeRW+rmYlzSuEbYJqg41r03zSfbfuNCfAhHYyjDc=";
            # }
            {
              publisher = "MoBalic";
              name = "jetbrains-new-dark";
              version = "0.0.1";
              sha256 = "sha256-hp1RoOacqM016NEtGXhdza4LxHZ0/rxyrTI2pwpjnas=";
            }
            {
              publisher = "hoovercj";
              name = "haskell-linter";
              version = "0.0.6";
              sha256 = "sha256-MjgqR547GC0tMnBJDMsiB60hJE9iqhKhzP6GLhcLZzk=";
              # Name: haskell-linter
              # Id: hoovercj.haskell-linter
              # Description: An extension to use hlint in vscode
              # Version: 0.0.6
              # Publisher: hoovercj
              # VS Marketplace Link: https://open-vsx.org/vscode/item?itemName=hoovercj.haskell-linter
            }

            # {
            #   publisher = "sheaf";
            #   name = "groovylambda";
            #   version = "0.1.0";
            #   sha256 = "sha256-bv1TgtFUYliKCorSvlyHABAZXVrbvBdUjepzDJI3XMg=";
            # }

            # {
            #   publisher = "janw4ld.";
            #   name = "lambda-black";
            #   version = "0.2.7";
            #   sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
            #   # Name: Lambda Black
            #   # Id: janw4ld.lambda-black
            #   # Description: Default dark+ theme with support for Haskell syntax colors and a black background variant.
            #   # Version: 0.2.7
            #   # Publisher: janw4ld
            #   # VS Marketplace Link: https://marketplace.visualstudio.com/items?itemName=janw4ld.lambda-black
            # }
            {
              publisher = "vscode-org-mode";
              name = "org-mode";
              version = "1.0.0";
              sha256 = "sha256-o9CIjMlYQQVRdtTlOp9BAVjqrfFIhhdvzlyhlcOv5rY=";
            }
          ]
      );
    userSettings = {
      "editor.fontSize" = 13;
      # "editor.fontFamily" = "FiraMono Nerd Font";
      "editor.fontFamily" = "DejaVu Sans Mono";
      "update.mode" = "none";
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
      "haskell.formattingProvider" = "fourmolu";
      # "workbench.statusBar.visible" = false;
      "[haskell]" = {
        "editor.defaultFormatter" = "haskell.haskell";

        "editor.formatOnSave" = true;
        "editor.fontFamily" = "DejaVu Sans Mono";
        "editor.fontSize" = 13;
        "editor.fontLigatures" = true;
      };
      "[purescript]" = {
        "editor.defaultFormatter" = "nwolverson.ide-purescript";
        "editor.formatOnSave" = true;
        "editor.fontFamily" = "DejaVu Sans Mono";
        "editor.fontSize" = 13;
        "editor.fontLigatures" = true;
      };
      # "workbench.colorTheme" = "JetBrains New Dark";
      "workbench.colorCustomizations" = {
        #ugly right now
        "statusBar.background" = "#282a33";
        "statusBar.noFolderBackground" = "#181819";
        "statusBar.debuggingBackground" = "#181819";
        # "editor.background" = "#32343d";
        "editor.background" = "#181819";
        "statusBarItem.remoteBackground" = "#181819";
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
        "password-store": "keychain"
      }
    '';
  };
}
