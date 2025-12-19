{
  inputs,
  host,
  ...
}: let
  # Import the host-specific variables.nix
  vars = import ../../hosts/${host}/variables.nix;
in {
  imports = [
    ./boot.nix
    ./flatpak.nix
    ./fonts.nix
    ./hardware.nix
    ./network.nix
    ./nfs.nix
    ./nh.nix
    ./quickshell.nix
    ./packages.nix
    ./sddm.nix
    ./security.nix
    ./services.nix
    ./stylix.nix
    ./system.nix
    ./thunar.nix
    ./user.nix
    ./xserver.nix
    ./cachix.nix
    inputs.stylix.nixosModules.stylix
  ];
}
