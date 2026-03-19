{ config, ... }:

{
  services.xserver.enable = true; # needed for NVIDIA drivers
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.production;

    # Keep the laptop dGPU eligible for runtime suspend when it is idle.
    powerManagement.enable = true;
    powerManagement.finegrained = false;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      # bus IDs set in hardware config
    };
  };
}
