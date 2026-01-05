{
  pkgs,
  inputs,
  lib,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
  noctaliaPkg = inputs.noctalia.packages.${system}.default;
  configDir = "${noctaliaPkg}/share/noctalia-shell";
in {
  # Install the Noctalia package
  home.packages = [
    noctaliaPkg
    pkgs.quickshell # Ensure quickshell is available for the service
  ];

  # Seed the configuration
  home.activation.seedNoctaliaShellCode = lib.hm.dag.entryAfter ["writeBoundary"] ''
    set -eu
    DEST="$HOME/.config/quickshell/noctalia-shell"
    SRC="${configDir}"

    if [ ! -d "$DEST" ]; then
      $DRY_RUN_CMD mkdir -p "$HOME/.config/quickshell"
      $DRY_RUN_CMD cp -R "$SRC" "$DEST"
      $DRY_RUN_CMD chmod -R u+rwX "$DEST"
    fi
  '';

  # Systemd User Service
  systemd.user.services.noctalia-shell = {
    Unit = {
      Description = "Noctalia Shell - Wayland desktop shell";
      Documentation = ["https://docs.noctalia.dev/docs"];
      PartOf = ["graphical-session.target"];
      After = ["graphical-session-pre.target"];
      Wants = ["graphical-session.target"];
    };

    Service = {
      # %h is the home directory specifier for systemd
      ExecStart = "${pkgs.quickshell}/bin/quickshell --path %h/.config/quickshell/noctalia-shell";
      Restart = "always";
      RestartSec = 5;
      # Combined QML paths for Qt6
      Environment = [
        "QML_IMPORT_PATH=${pkgs.qt6.qt5compat}/lib/qt-6/qml:${pkgs.qt6.qtbase}/lib/qt-6/qml"
        "QML2_IMPORT_PATH=${pkgs.qt6.qt5compat}/lib/qt-6/qml:${pkgs.qt6.qtbase}/lib/qt-6/qml"
      ];
    };

    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };
}
