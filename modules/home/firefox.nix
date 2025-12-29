{ config, lib, pkgs, inputs, ... }:

let
  # Use NUR’s legacyPackages output so we avoid the <nixpkgs> pure‑mode error.
  nurPkgs = inputs.nur.legacyPackages."x86_64-linux";
in
{
  # Don’t set home.stateVersion here (central in your core user module).

  programs.firefox = {
    enable = true;

    profiles.default = {
      id = 0;
      isDefault = true;

      # Firefox preferences
      settings = {
        "extensions.autoDisableScopes" = 0;
        "extensions.enabledScopes" = 15;
        "privacy.resistFingerprinting" = true;
        "browser.search.suggest.enabled" = false;
      };

      # Extra raw prefs, if you want more
      extraConfig = lib.concatStringsSep "\n" [
        # Example extra prefs
        ''user_pref("layout.spellcheckDefault", true);''
        ''user_pref("widget.use-xdg-desktop-portal.file-picker", true);''
      ];

      # Search engine config
      search.default = "ddg";
      search.engines = {
        ddg = {
          urls = [
            { template = "https://duckduckgo.com/?q={searchTerms}"; }
          ];
          definedAliases = [ "ddg" ];
        };
        brave = {
          urls = [
            { template = "https://search.brave.com/search?q={searchTerms}&summary=0"; }
          ];
          definedAliases = [ "brave" ];
        };
        osm = {
          urls = [
            { template = "https://www.openstreetmap.org/search?query={searchTerms}"; }
          ];
          definedAliases = [ "osm" ];
        };
        wiki = {
          urls = [
            { template = "https://en.wikipedia.org/wiki/Special:Search?search={searchTerms}"; }
          ];
          definedAliases = [ "wiki" ];
        };
      };

      # Extensions from NUR
      extensions.packages = with nurPkgs.repos.rycee.firefox-addons; [
        ublock-origin
        privacy-badger
      ];
    };
  };

  # Tell Stylix which Firefox profile names to apply styling to.
  # Stylix requires this explicitly due to module system limitations. :contentReference[oaicite:0]{index=0}
  stylix.targets.firefox.profileNames = [ "default" ];
}
