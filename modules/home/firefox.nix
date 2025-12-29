{ config, pkgs, lib, inputs, ... }:

let
  # Import NUR so we can use firefox addon packages
  nurPkgs = import inputs.nur {
    inherit pkgs;
  };

  # Helper to add raw prefs via extraConfig
  rawPrefs = lib.concatMapStringsSep "\n" (name: value:
    "user_pref(${lib.strings.toJSON name}, ${lib.strings.toJSON value});"
  ) (lib.attrNames config.firefoxRawSettings or {});

in
{
  # Optional: if you also want zen-browser config compatibility
  # config.firefoxRawSettings = { "extensions.autoDisableScopes" = 0; "extensions.enabledScopes" = 15; };

  programs.firefox = {
    enable = true;

    # Use wrapped firefox so HW acceleration, policies, etc. behave
    package = pkgs.wrapFirefox pkgs.firefox-unwrapped { };

    # Global enterprise policies (like your zen-browser example)
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DontCheckDefaultBrowser = true;
      FirefoxSuggest = {
        WebSuggestions = false;
        SponsoredSuggestions = false;
        ImproveSuggest = false;
        Locked = true;
      };
      UserMessaging = {
        ExtensionRecommendations = false;
        UrlbarInterventions = false;
        SkipOnboarding = true;
        MoreFromMozilla = false;
        FirefoxLabs = true;
      };
    };

    profiles.default = {
      id = 0;
      isDefault = true;

      # From your zen-browser prefs + my suggestions
      settings = {
        "layout.spellcheckDefault" = 1;
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        "privacy.resistFingerprinting" = true;
        "browser.search.suggest.enabled" = false;
        "browser.urlbar.suggest.searches" = false;
      };

      # Extra raw prefs like `extensions.*Scopes = …`
      extraConfig = rawPrefs;

      # Extensions via NUR
      extensions = with nurPkgs.repos.rycee.firefox-addons; [
        ublock-origin
        privacy-badger
      ];

      # Search engine settings
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

