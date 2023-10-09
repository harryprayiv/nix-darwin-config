{
  config,
  pkgs,
  ...
}: let
  api_key = builtins.readFile /home/bismuth/plutus/Documents/Credentials/davinci_api_key.txt;
  curl = "${pkgs.curl}/bin/curl";
  jq = "${pkgs.jq}/bin/jq";
  sed = "${pkgs.gnused}/bin/sed";
  # ponysay  = "${pkgs.ponysay}/bin/ponysay";
in
  pkgs.writeShellScriptBin "ai_filter" ''
    prompt=$1
    ${curl} https://api.openai.com/v1/completions -s \
    -H 'Content-Type: application/json' \
    -H 'Authorization: Bearer ${api_key}' \
    -d '{
    "model": "text-davinci-003",
    "prompt": "'"$prompt"'",
    "max_tokens": 3000,
    "temperature": 0
    }' | ${jq} '.choices' | ${jq} -r '.[0].text' | ${sed} 's/"//g'
  ''
