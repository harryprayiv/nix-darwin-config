{pkgs, ...}: let
  pgrep = "${pkgs.busybox}/bin/pgrep";
in
  pkgs.writeShellScriptBin "vpn_status" ''
    if [ "$(${pgrep} openvpn)" ]; then
        echo ""
    else
        echo ""
    fi
  ''
