{ config, lib, pkgs, inputs, ... }:

let
  # Use NUR’s legacyPackages output so we avoid the <nixpkgs> pure‑mode error.
  nurPkgs = inputs.nur.legacyPackages."x86_64-linux";
in
{
  programs.firefox = {
    enable = true;

    # Firefox Language Packs
    languagePacks = [ "en-US" "de" "en-GB" ];

    # Merged Policies from both configs
    policies = {
      #### DEBLOAT ###
      DisableFirefoxStudies = true;
      DontCheckDefaultBrowser = true;
      UserMessaging = {
        ExtensionRecommendations = false;
        UrlbarInterventions = false;
        SkipOnboarding = true;
        MoreFromMozilla = false;
        FirefoxLabs = true;
      };
      FirefoxSuggest = {
        WebSuggestions = false;
        SponsoredSuggestions = false;
        ImproveSuggest = false;
        Locked = true;
      };
      HttpsOnlyMode = "force_enabled";
      SSLVersionMin = "tls1.2";
      PostQuantumKeyAgreementEnabled = true;

      #### SECURITY ###
      DisableTelemetry = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      DisablePocket = true;
      NetworkPrediction = false;

      # Delete data on shutdown


      Cookies = {
        Allow = [
          "https://github.com"
          "https://gitlab.com"
          "https://codeberg.org"
          "https://sr.ht"
          "http://127.0.0.1"
          "https://127.0.0.1"
          "http://localhost"
          "https://localhost"
          "https://192.168.1.1"
        ];
      };

      # Search Engine Preferences
      SearchEngines = {
        Remove = [
          "eBay"
          "Google"
          "Bing"
          "Ecosia"
          "Wikipedia"
          "Perplexity"
        ];
        Add = [
          {
            "Name" = "Brave Search";
            "URLTemplate" = "https://search.brave.com/search?q={searchTerms}&summary=0";
            "IconURL" = "https://cdn.search.brave.com/serp/v1/static/brand/eebf5f2ce06b0b0ee6bbd72d7e18621d4618b9663471d42463c692d019068072-brave-lion-favicon.png";
            "Alias" = "brave";
          }
          {
            "Name" = "DuckDuckGo";
            "URLTemplate" = "https://duckduckgo.com/?q={searchTerms}&ia=web&assist=false";
            "IconURL" = "https://duckduckgo.com/favicon.ico";
            "Alias" = "ddg";
            "Description" = "Duckduckgo without AI integrations";
          }
          {
            "Name" = "OpenStreetMap";
            "URLTemplate" = "https://www.openstreetmap.org/search?query={searchTerms}";
            "IconURL" = "https://www.openstreetmap.org/favicon.ico";
            "Alias" = "osm";
          }
          {
            "Name" = "Wikipedia";
            "URLTemplate" = "https://en.wikipedia.org/wiki/Special:Search?go=Go&search={searchTerms}";
            "IconURL" = "https://en.wikipedia.org/favicon.ico";
            "Alias" = "wiki";
          }
        ];
        Default = "ddg";
      };
    };

    # Merged Extension Settings (both yours and your brother's)
    extensions.packages = with nurPkgs.repos.rycee.firefox-addons; [
      ublock-origin
      privacy-badger
      # Your brother's extensions
      ublock0@raymondhill.net
      plasma-browser-integration@kde.org
      keepassxc-browser@keepassxc.org
      {b11bea1f-a888-4332-8d8a-cec2be7d24b9}  # Snowflake
      # Tampermonkey extension is commented out in your brother's config
      # firefox@tampermonkey.net
      {531906d3-e22f-4a6c-a102-8057b88a1a63}  # SingleFile
      jid1-QoFqdK4qzUfGWQ@jetpack  # Dark Background and Light Text
    ];

    # Merged Preferences (from both configs)
    preferences = lib.mergeAttrs [
      {
        # Basic Settings
        "layout.spellcheckDefault" = 1;
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        "extensions.webextensions.restrictedDomains" = "";
        "media.webrtc.camera.allow-pipewire" = true;
        "browser.download.always_ask_before_handling_new_types" = true;

        # Privacy Settings
        "privacy.resistFingerprinting" = "true";
        "browser.safebrowsing.downloads.remote.enabled" = false;
        "network.dns.disablePrefetch" = false;
        "network.predictor.enabled" = false;
        "network.http.speculative-parallel-limit" = 0;
        "browser.places.speculativeConnect.enabled" = "false";
        "privacy.globalprivacycontrol.enabled" = true;
        "privacy.clearOnShutdown_v2.cookiesAndStorage" = true;
        "privacy.fingerprintingProtection" = true;

        "browser.contentblocking.category" = "strict";
        "extensions.pocket.enabled" = false;
        "browser.search.suggest.enabled" = false;
        "browser.urlbar.suggest.searches" = false;
        "browser.privatebrowsing.forceMediaMemoryCache" = true;
      }
      # Security-related preferences
      {
        "security.ssl.require_safe_negotiation" = true;
        "security.tls.enable_0rtt_data" = 2;
        "security.cert_pinning.enforcement_level" = 2;
        "security.pki.crlite_mode" = 2;
        "security.ssl.treat_unsafe_negotiation_as_broken" = true;
        "browser.xul.error_pages.expert_bad_cert" = true;
      }
    ];

    # Optional - Bookmark Configuration (if needed)
    # bookmarks = [
    #   { title = "DuckDuckGo"; url = "https://duckduckgo.com" };
    #   { title = "GitHub"; url = "https://github.com" };
    #   { title = "Wikipedia"; url = "https://en.wikipedia.org" };
    # ];

    # This is how you would set up bookmark configuration, but if it's too specific, you can leave it out for now.
    # If you want, I can help with specific bookmark additions.
  };
}

