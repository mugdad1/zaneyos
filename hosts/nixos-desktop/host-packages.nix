{pkgs, ...}: {
  environment.systemPackages = with pkgs; 
  ++ [
  amdsmi
  
  ];
  # Add host specific flatpaks here
  services = {
    flatpak = {
      packages = [
      ];
    };
  };
}
