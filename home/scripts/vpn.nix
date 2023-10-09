{pkgs, ...}: let
  systemctl = "/run/current-system/sw/bin/systemctl";
  sysctl = "/run/current-system/sw/bin/sysctl";
  vpn_name = "switzerland";
  # "portugal" | "spain" | "netherlands" | "iceland"
  # "thailand"  | "japan" | "denmark" | "south_korea"
  openvpn = "${pkgs.openvpn}/bin/openvpn";
  kill = "${pkgs.killall}/bin/killall";
  downloader = "${pkgs.transmission-gtk}/bin/transmission-gtk";
in
  pkgs.writeShellScriptBin "vpn" ''

    if ${systemctl} is-active "openvpn-${vpn_name}.service" > /dev/null; then
        ${kill} transmission-gtk
        sudo ${sysctl} -w net.ipv6.conf.all.disable_ipv6=0
        sudo ${systemctl} stop "openvpn-${vpn_name}.service"
        echo ATTN: Your IP is now Vulnerable: VPN Stopped
    else
        echo Disabling ipv6...
        sudo ${sysctl} -w net.ipv6.conf.all.disable_ipv6=1
        echo Starting VPN...
        sudo ${systemctl} start "openvpn-${vpn_name}.service"
    fi
  ''
