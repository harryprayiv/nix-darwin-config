{pkgs, ...}: let
  bobthefish = {
    name = "theme-bobthefish";
    src = inputs.pkgs.fish-bobthefish-theme;
  };

  keytool-completions = {
    name = "keytool-completions";
    src = inputs.pkgs.fish-keytool-completions;
  };
in {
  completions = {
    keytool = builtins.readFile "${keytool-completions.src}/completions/keytool.fish";
  };

  theme = bobthefish;
  prompt = builtins.readFile "${bobthefish.src}/fish_prompt.fish";
}
