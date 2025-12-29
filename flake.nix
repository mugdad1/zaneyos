{
  description = "ZaneyOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ✦ Add NUR
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf.url = "github:notashelf/nvf";
    stylix.url = "github:danth/stylix/release-25.11";
    nix-flatpak.url = "github:gmodena/nix-flatpak?ref=latest";
    noctalia = { url = "github:noctalia-dev/noctalia-shell"; inputs.nixpkgs.follows = "nixpkgs"; };
    nixvim = { url = "github:nix-community/nixvim/nixos-25.11"; inputs.nixpkgs.follows = "nixpkgs"; };
    antigravity-nix = { url = "github:jacopone/antigravity-nix"; inputs.nixpkgs.follows = "nixpkgs"; };
    zen-browser = { url = "github:youwen5/zen-browser-flake"; inputs.nixpkgs.follows = "nixpkgs"; };
    alejandra = { url = "github:kamadorueda/alejandra"; inputs.nixpkgs.follows = "nixpkgs"; };
  };

  outputs = { self, nixpkgs, home-manager, nur, nix-flatpak, nixvim, alejandra, ... } @ inputs:
  let
    system = "x86_64-linux";
    host = "nixos-desktop";
    profile = "intel";
    username = "mugdad";

    pkgs = import nixpkgs {
      inherit system;
      overlays = []; # no need to overlay NUR here
    };

    mkNixosConfig = gpuProfile: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs username host profile; };

      modules = [
        ./modules/core/overlays.nix
        ./profiles/${gpuProfile}
        nix-flatpak.nixosModules.nix-flatpak
      ];
    };
  in
  {
    nixosConfigurations = {
      amd = mkNixosConfig "amd";
      nvidia = mkNixosConfig "nvidia";
      nvidia-laptop = mkNixosConfig "nvidia-laptop";
      amd-hybrid = mkNixosConfig "amd-hybrid";
      intel = mkNixosConfig "intel";
      vm = mkNixosConfig "vm";
    };

    formatter.${system} = alejandra.packages.${system}.default;
  };
}

