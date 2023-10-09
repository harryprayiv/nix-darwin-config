{pkgs, ...}: let
  curl = "${pkgs.curl}/bin/curl";
  jq = "${pkgs.jq}/bin/jq";
  sed = "${pkgs.gnused}/bin/sed";
in
  pkgs.writeShellScriptBin "ada" ''
    echo $(${curl} -s "https://api.coingecko.com/api/v3/coins/cardano" | ${jq} '.market_data.current_price.usd' | ${sed} 's/"//g')
  ''
