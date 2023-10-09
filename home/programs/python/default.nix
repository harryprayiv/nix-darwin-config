{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  pythonExt = p:
    with p; [
      # pandas
      # requests
      pip
      # numpy
      # packaging
      # impacket
      # dsinternals
      # pypykatz
      # lsassy
    ];

  pythonPkgs = with pkgs ++ pythonExt; [
    (pkgs.python3.withPackages pythonExt)
  ];

  pythonStuff = with pkgs; [
    # poetry
    python3Packages.ipython
    jupyter # pyton jupyter notebooks
  ];
in {
  home.packages = pythonPkgs ++ pythonStuff;
}
