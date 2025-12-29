{ config, lib, pkgs, inputs, ... }:

let
  # Use NUR’s legacyPackages output so we avoid the <nixpkgs> pure‑mode error.
  nurPkgs = inputs.nur.legacyPackages."x86_64-linux";
in

{
  # Optional: state version for Home Manager (set early)
  home.stateVersion = "25.11";

  programs.firefox = {
    enable = true;

    # Define a profile named "default"
    profiles.default = {
      id = 0;
      isDefault = true;

      # Firefox preferences (about:config)
      settings = {
        "extensions.autoDisableScopes" = 0;
        "extensions.enabledScopes" = 15;
        "privacy.resistFingerprinting" = true;
        "browser.search.suggest.enabled" = false;
      };

      # Install extensions from NUR’s firefox‑addons repository
      # using `inputs.nur.legacyPackages`, which avoids the <nixpkgs> importing issue.
      extensions.packages = with nurPkgs.repos.rycee.firefox-addons; [
        ublock-origin
        privacy-badger
      ];

      # Example search engine configuration
      search.default = "DuckDuckGo";
      search.engines = {
        DuckDuckGo = {
          urls = [
            { template = "https://duckduckgo.com/?q={searchTerms}"; }
          ];
          definedAliases = [ "ddg" ];
        };
        BraveSearch = {
          urls = [
            { template = "https://search.brave.com/search?q={searchTerms}&summary=0"; }
          ];
          definedAliases = [ "brave" ];
        };
      };
    };
  };
}

