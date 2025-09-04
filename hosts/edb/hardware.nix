{ inputs, config, lib, pkgs, ... }:
{
  imports = [
    inputs.nixpkgs.nixosModules.notDetected
    inputs.nixos-hardware.nixosModules.apple-macbook-pro-11-4
  ];

  hardware.graphics.enable = true;

  # Force i965 VA-API driver
  environment.sessionVariables = { LIBVA_DRIVER_NAME = "i965"; };

  # CPU frequency scaling
  services.thermald.enable = true;


  # Faster wakeups from suspend
  systemd.sleep.extraConfig = ''
    MemorySleepMode=s2idle
  '';

  # Make fans as quite as possible
  # It is probably not a good idea to let the laptop run this hot. Use at your own risk
  services.mbpfan.settings.general = {
    low_temp = 60;  # If temperature is below this, fans will run at minimum speed
    high_temp = 85; # If temperature is above this, fan speed will gradually increase
    max_temp = 95;  # If temperature is above this, fans will run at maximum speed
  };

  # Make accidental presses of the power key a little more forgiving
  services.logind.settings.Login = {
    HandlePowerKey = "ignore";
    HandlePowerKeyLongPress = "poweroff";
  };

  # Boot and module stuff
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # Avoid flickering on boot
  boot.kernelParams = [ "i915.fastboot=1" ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/047f4ab3-a427-4d58-b163-1eb615317d1e";
    fsType = "btrfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/FA70-7B0F";
    fsType = "vfat";
  };

  swapDevices = [ {
    device = "/var/lib/swapfile";
    size = 16*1024;
  } ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
