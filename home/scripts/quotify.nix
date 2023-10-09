{pkgs, ...}: let
  xsel = "${pkgs.xsel}/bin/xsel";
in
  pkgs.writeShellScriptBin "quote" ''
    # Get the current clipboard content.
    clipboard_content=$(xsel --clipboard --output)

    # Add '> ' at the beginning of each line.
    formatted_content=$(echo "$clipboard_content" | sed 's/^/> /')

    # Replace the clipboard content.
    echo "$formatted_content" | xsel --clipboard --input

    # Output the new clipboard content.
    xsel --clipboard --output
  ''
