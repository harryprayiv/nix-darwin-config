{pkgs, ...}: let
  pgrep = "${pkgs.busybox}/bin/pgrep";
in
  pkgs.writeShellScriptBin "cnodeStatus" ''
    if [ "$(${pgrep} cardano-node)" ]; then
        echo ""
    else
        echo ""
    fi
  ''
