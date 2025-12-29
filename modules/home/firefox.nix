{
  config,
  pkgs,
  ...
}: let
  # Check about:support for extension/add-on ID strings.
  extensions = [
    "uBlock0@raymondhill.net" # uBlock Origin
    "plasma-browser-integration@kde.org" # Plasma browser integration
    "keepassxc-browser@keepassxc.org" # KeePassXC Integration
    "{b11bea1f-a888-4332-8d8a-cec2be7d24b9}" # Snowflake
    #"firefox@tampermonkey.net"                 # TamperMonkey
    "{531906d3-e22f-4a6c-a102-8057b88a1a63}" # SingleFile
    "jid1-QoFqdK4qzUfGWQ@jetpack" # Dark Background and Light Text
  ];
in {
  programs.firefox = {
    enable = true;
    languagePacks = ["en-US" "de" "en-GB"];

    # Check about:policies#documentation for options.
    policies = {
      #### DEBLOAT ###
      DisableFirefoxStudies = true;
      #DisableFirefoxScreenshots = true;
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

      #### SECURITY ###
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;
      HttpsOnlyMode = "force_enabled";
      SSLVersionMin = "tls1.2";
      PostQuantumKeyAgreementEnabled = true;
      HttpAllowlist = [
        "http://localhost"
        "http://127.0.0.1"
      ];

      #### PRIVACY ###
      DisableTelemetry = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
        Exceptions = [
          "https://netflix.com"
          "https://amazon.de"
          "https://spotify.com"
        ];
      };
      DisablePocket = true;
      NetworkPrediction = false;

      # Delete data on shutdown
      SanitizeOnShutdown = {
        Cache = true;
        FormData = true;
        SiteSettings = true;
        OfflineApps = true;
      };

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

          # specific sites
          "..."
        ];
      };

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
        Default = "DuckDuckGo";
      };
      SearchSuggestEnabled = false;

      ExtensionSettings = builtins.listToAttrs (builtins.map (id: {
          name = id;
          value = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/${id}/latest.xpi";
            installation_mode = "force_installed";
          };
        })
        extensions);
    };

    preferences = {
      #### FEATURES ###
      "layout.spellcheckDefault" = 1;
      # Use the systems native filechooser portal
      "widget.use-xdg-desktop-portal.file-picker" = 1;
      # allow adblockers to act everywhere. WARNING this is a security hole.
      "extensions.webextensions.restrictedDomains" = "";
      "media.webrtc.camera.allow-pipewire" = true;
      "browser.download.always_ask_before_handling_new_types" = true;

      #### DEBLOAT ###
      "browser.discovery.enabled" = false;
      "app.shield.optoutstudies.enabled" = false;
      "browser.topsites.contile.enabled" = false;
      "browser.urlbar.suggest.quicksuggest.sponsored" = false;
      "browser.urlbar.trending.featureGate" = false;
      "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
      "browser.newtabpage.activity-stream.feeds.snippets" = false;
      "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
      "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = false;
      "browser.newtabpage.activity-stream.section.highlights.includeDownloads" = false;
      "browser.newtabpage.activity-stream.section.highlights.includeVisited" = false;
      "browser.newtabpage.activity-stream.showSponsored" = false;
      "browser.newtabpage.activity-stream.system.showSponsored" = false;
      "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
      # Privacy: Disable automatic opening in new windows (manually still works)
      # https://gitlab.torproject.org/tpo/applications/tor-browser/-/issues/9881
      "browser.link.open_newwindow" = 3;
      # Privacy: Set all window open modes to abide above method
      "browser.link.open_newwindow.restriction" = 0;

      #### PRIVACY ###
      "privacy.resistFingerprinting" = "true";
      # disable sending downloaded files to the internet
      "browser.safebrowsing.downloads.remote.enabled" = false;
      "network.dns.disablePrefetch" = false;
      # redundancy: disable network prefetching
      "network.predictor.enabled" = false;
      # disable preloading websites when hovering over links
      "network.http.speculative-parallel-limit" = 0;
      # disable connecting to bookmarks when hovering over them
      "browser.places.speculativeConnect.enabled" = "false";
      "privacy.globalprivacycontrol.enabled" = true;
      "privacy.clearOnShutdown_v2.cookiesAndStorage" = true;
      "privacy.fingerprintingProtection" = true;

      "browser.contentblocking.category" = "strict";
      "extensions.pocket.enabled" = false;
      "browser.search.suggest.enabled" = false;
      "browser.search.suggest.enabled.private" = false;
      "browser.urlbar.suggest.searches" = false;
      # store media in cache only on private browsing
      "browser.privatebrowsing.forceMediaMemoryCache" = true;
      "network.http.referer.XOriginTrimmingPolicy" = 2;
      # Privacy: Disable CSP reporting
      # https://bugzilla.mozilla.org/show_bug.cgi?id=1964249
      "security.csp.reporting.enabled" = false;

      #### SECURITY ###
      #"browser.formfill.enable" = false;
      "pdfjs.enableScripting" = false;
      #"signon.autofillForms" = false
      # UNCLEAR
      "signon.formlessCapture.enabled" = false;
      # prevent scripts from moving or resizing windows
      "dom.disable_window_move_resize" = true;
      # Security: Disable remote debugging feature
      # https://gitlab.torproject.org/tpo/applications/tor-browser/-/issues/16222
      "devtools.debugger.remote-enabled" = false;
      # Security: Restrict directories from which extensions can be loaded (Unclear)
      # https://archive.is/DYjAM
      "extensions.enabledScopes" = 5;

      #### SSL ###
      # Security: Require safe SSL negotiation to avoid potentially MITMed sites
      "security.ssl.require_safe_negotiation" = true;
      # Security: Disable TLS1.3 0-RTT as key encryption may not be forward secret
      # https://github.com/tlswg/tls13-spec/issues/1001
      "security.tls.enable_0rtt_data" = 2;
      # Security: Enable strict public key pinning, prevents some MITM attacks
      "security.cert_pinning.enforcement_level" = 2;
      # Security: Enable CRLite to ensure that revoked certificates are detected
      "security.pki.crlite_mode" = 2;
      # Security: Treat unsafe negotiation as broken
      # https://wiki.mozilla.org/Security:Renegotiation
      # https://bugzilla.mozilla.org/1353705
      "security.ssl.treat_unsafe_negotiation_as_broken" = true;
      #  Security: Display more information on Insecure Connection warning pages
      # Test: https://badssl.com
      "browser.xul.error_pages.expert_bad_cert" = true;
    };
  };
}
