{ config, lib, pkgs, inputs, ... }:

let
  nurPkgs = inputs.nur.legacyPackages."x86_64-linux";

  # Extensions that are NOT in NUR → install via policy by ID
  forcedExtensions = [
    "plasma-browser-integration@kde.org"
    "keepassxc-browser@keepassxc.org"
    "{b11bea1f-a888-4332-8d8a-cec2be7d24b9}" # Snowflake
    "{531906d3-e22f-4a6c-a102-8057b88a1a63}" # SingleFile
    "jid1-QoFqdK4qzUfGWQ@jetpack"            # Dark Background Light Text
  ];
in
{
  programs.firefox = {
    enable = true;

    profiles.default = {
      id = 0;
      isDefault = true;

      settings = {
        "privacy.resistFingerprinting" = true;
        "browser.search.suggest.enabled" = false;
        "extensions.enabledScopes" = 15;
      };

      extraConfig = lib.concatStringsSep "\n" [
        ''user_pref("layout.spellcheckDefault", 1);''
        ''user_pref("widget.use-xdg-desktop-portal.file-picker", 1);''
      ];

      search.default = "ddg";
      search.engines = {
        ddg = {
          urls = [{ template = "https://duckduckgo.com/?q={searchTerms}"; }];
          definedAliases = [ "ddg" ];
        };
        brave = {
          urls = [{ template = "https://search.brave.com/search?q={searchTerms}&summary=0"; }];
          definedAliases = [ "brave" ];
        };
        osm = {
          urls = [{ template = "https://www.openstreetmap.org/search?query={searchTerms}"; }];
          definedAliases = [ "osm" ];
        };
        wiki = {
          urls = [{ template = "https://en.wikipedia.org/wiki/Special:Search?search={searchTerms}"; }];
          definedAliases = [ "wiki" ];
        };
      };

      # ONLY NUR-packaged extensions here
      extensions.packages = with nurPkgs.repos.rycee.firefox-addons; [
        ublock-origin
        privacy-badger
      ];
    };

    #### Firefox enterprise policies (safe, global)
    policies = {
      DisableTelemetry = true;
      DisablePocket = true;
      DontCheckDefaultBrowser = true;
      HttpsOnlyMode = "force_enabled";

      ExtensionSettings =
        builtins.listToAttrs (map (id: {
          name = id;
          value = {
            install_url =
              "https://addons.mozilla.org/firefox/downloads/latest/${id}/latest.xpi";
            installation_mode = "force_installed";
          };
        }) forcedExtensions);
    };
  };

  # Stylix
  stylix.targets.firefox.profileNames = [ "default" ];
}

