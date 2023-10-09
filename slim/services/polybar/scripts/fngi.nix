{pkgs, ...}: let
  curl = "${pkgs.curl}/bin/curl";
  jq = "${pkgs.jq}/bin/jq";
  sed = "${pkgs.gnused}/bin/sed";
in
  pkgs.writeShellScriptBin "fngi" ''
    fng=$(${curl} -s "https://api.alternative.me/fng/" | ${jq} '.data[0]' | ${jq} '.value' | ${sed} 's/"//g')

    echo -n "$fng"
  ''
