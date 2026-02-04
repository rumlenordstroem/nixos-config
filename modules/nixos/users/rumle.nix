{ inputs, config, lib, pkgs, ... }:

with lib;

let
  cfg = config.users.rumle;
in
{
  options.users.rumle.enable = mkEnableOption "Add rumle as user";

  config = mkIf cfg.enable {
    users.users.rumle = {
      description = "Rumle Nordstrøm";
      isNormalUser = true;
      shell = config.programs.fish.package;
      extraGroups = [
        "wheel"
        "video"
        "dialout"
        (mkIf config.networking.networkmanager.enable "networkmanager")
        (mkIf config.virtualisation.libvirtd.enable "libvirtd")
        (mkIf config.virtualisation.docker.enable "docker")
        (mkIf config.virtualisation.virtualbox.host.enable "vboxusers")
      ];
      hashedPassword = "$y$j9T$.uZNPXk3OFWaoNetj2P2e0$6rD7ex86u17L78b0wKQ.QzXd3cZUVkAPifTs7r.L3l5";
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCvT9oPm1+tMYdUp4pngUjDciJpKP0kPlxmyJDQh6+Nb7f2AwW+C7BGEPADcf0yHtG8FYW/9MkfpCZcMoatsMSQnW1Wtzf3Xrjl59AGhuGc9Yc5stC6JLgWhosNpVoiZ44s0lU7vxMMVws+dBqmnanjYOqsKkVMBhmel9pfusY+gFvhRLGJQB98Ck+D5h/5VLefidM8d4hcnt0CK8+4/jMNIPojyx5j63yAG4vKZemJVgeBUM3enftfi7onY7xpuI7dhY4jWnp0JnPww8VIYHrbfZRc3XdpeTVMWF7oZB05nqkuOYUPanQp4jDIf/tdJTHwvv2ZnxmuxwheeLNDw2lMSmuogX2Zv+x91CHHHAWJFEWrcv7CKSL5LDS8fuw4Nw1Y/tjtZIIMfCXGLvxinZVAnCF/OOpyPNZIxn0bqrIVO42cF0smciWEeEIzvtiTzNJXdhIO/eg9dOWnBAq+PYIl+LxsCYrqcFgrhol9a6yX/DlUFBAbRbvuEY3SIVFV5O0= madsrumlenordstrom@arch"
      ];
    };

    programs = {
      fish.enable = true;
      localsend.enable = true;
      nix-index.enable = true;
      command-not-found.enable = false;
    };
  };
}
