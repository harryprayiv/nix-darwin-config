let
  scripts = {
    config,
    pkgs,
    ...
  }: let
    gen-ssh-key = pkgs.callPackage ./gen-ssh-key.nix {inherit pkgs;};
    hcr = pkgs.callPackage ./changes-report.nix {inherit config pkgs;};
    hms = pkgs.callPackage ./switcher.nix {inherit config pkgs;};
    kls = pkgs.callPackage ./keyboard-layout-switch.nix {inherit pkgs;};
    szp = pkgs.callPackage ./show-zombie-parents.nix {inherit pkgs;};
    node_toggle = pkgs.callPackage ./node_toggle.nix {inherit config pkgs;};
    node_check = pkgs.callPackage ./node_check.nix {inherit config pkgs;};
    hue_tools = pkgs.callPackage ./hue_tools.nix {inherit pkgs;};
    mru = pkgs.callPackage ./mru.nix {inherit config pkgs;};
    ai-query = pkgs.callPackage ./ai/ai_query.nix {inherit config pkgs;};
    ai-filter = pkgs.callPackage ./ai/ai_filter.nix {inherit config pkgs;};
    aipq = pkgs.callPackage ./ai/persona_query.nix {inherit config pkgs;};
    aipf = pkgs.callPackage ./ai/persona_filter.nix {inherit config pkgs;};
  in {
    home.packages = [
      hcr # home-manager changes report between generations
      gen-ssh-key # generate ssh key and add it to the system
      kls # switch keyboard layout
      szp # show zombie parents
      node_toggle # launch cardano-node
      node_check # cardano node monitor script
      hue_tools # tools for interacting with hue lights
      mru # repo download
      ai-query # openAI chat prompt cli
      ai-filter # openAI text in-out
      aipq # openAI persona query
      aipf # openAI persona filter
      #hms               # custom home-manager switcher that considers the current DISPLAY
      #ipad-mirror
    ];
  };
in [scripts]
