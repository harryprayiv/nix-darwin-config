{
  description = "Harry's Darwin System";

  inputs = {
    # Package sets
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-21.11-darwin";
    nixpkgs-unstable.url = github:NixOS/nixpkgs/nixpkgs-unstable;

    # Environment/system management
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

    fish-bobthefish-theme = {
      url = github:harryprayiv/theme-bobthefish;
      flake = false;
    };
    fish-keytool-completions = {
      url = github:ckipp01/keytool-fish-completions;
      flake = false;
    };

    # Other sources
    # comma = {
    #   url = github:nix-community/comma;
    #   flake = false;
    # };
  };

  outputs = {
    self,
    darwin,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    inherit (darwin.lib) darwinSystem;

    fish-bobthefish-theme = import inputs.fish-bobthefish-theme {pkgs = nixpkgs.legacyPackages.x86_64-darwin;};
    fish-keytool-completions = import inputs.fish-keytool-completions {pkgs = nixpkgs.legacyPackages.x86_64-darwin;};
    # commaPkg = import inputs.comma {pkgs = nixpkgs.legacyPackages.x86_64-darwin;};

    myOverlays = [
      (final: prev: {
        # comma = commaPkg;
        fish-bobthefish-theme = fish-bobthefish-theme;
        fish-keytool-completions = fish-keytool-completions;
      })
    ];

    nixpkgsConfig = {
      config = {allowUnfree = true;};
      overlays = myOverlays;
    };
  in {
    darwinConfigurations = {
      macbook = darwinSystem {
        system = "x86_64-darwin";
        modules = [
          {nixpkgs = nixpkgsConfig;}
          ./system/configuration_mac.nix
          ./system/machine/macbook
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.bismuth = import ./home_mac/home.nix;
          }
        ];
      };
    };
  };
}
