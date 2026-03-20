{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    rocmPackages.amdsmi
  ];
}
