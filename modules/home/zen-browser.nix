{ pkgs
, lib
, inputs
, ... }:

let
  extension = shortId: guid: {
    name = guid;
    value = {
      install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
      installation_mode = "normal_installed";
    };
  };

  prefs = {
    "extensions.autoDisableScopes" = 0;
    "extensions.pocket.enabled" = false;
  };

  extensions = [
    (extension "ublock-origin" "uBlock0@raymondhill.net")
  ];

  # use the beta variant
  zenPkg = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.beta;
in
{
  home.packages = [
    zenPkg
  ];

  home.file.".config/zen-browser/policies.json".text = builtins.toJSON {
    DisableTelemetry = true;
    ExtensionSettings = builtins.listToAttrs extensions;
    SearchEngines = {
      Default = "ddg";
      Add = [
        {
          Name        = "nixpkgs packages";
          URLTemplate = "https://search.nixos.org/packages?query={searchTerms}";
          IconURL     = "https://wiki.nixos.org/favicon.ico";
          Alias       = "@np";
        }
        {
          Name        = "NixOS options";
          URLTemplate = "https://search.nixos.org/options?query={searchTerms}";
          IconURL     = "https://wiki.nixos.org/favicon.ico";
          Alias       = "@no";
        }
        {
          Name        = "NixOS Wiki";
          URLTemplate = "https://wiki.nixos.org/w/index.php?search={searchTerms}";
          IconURL     = "https://wiki.nixos.org/favicon.ico";
          Alias       = "@nw";
        }
        {
          Name        = "noogle";
          URLTemplate = "https://noogle.dev/q?term={searchTerms}";
          IconURL     = "https://noogle.dev/favicon.ico";
          Alias       = "@ng";
        }
      ];
    };
  };

  home.file.".config/zen-browser/mozprefs.js".text = lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value:
    "lockPref(${lib.strings.toJSON name}, ${lib.strings.toJSON value});"
  ) prefs);
}

