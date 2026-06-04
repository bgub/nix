{ ... }:

{
  services.xserver.enable = true; # needed for NVIDIA drivers
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;

  hardware.nvidia = {
    open = false;

    # Keep the laptop dGPU eligible for runtime suspend when it is idle.
    powerManagement.enable = true;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      # bus IDs set in hardware config
    };
  };
}
