{ inputs, config, lib, pkgs, ... }:
{
  users.rumle.enable = true;

  home = {
    stateVersion = "26.05";
  };

  # services.syncthing = {
  #   enable = true;
  #   settings = {
  #     folders = {
  #       dcim = {
  #         id = "dcim";
  #         path = "~/DCIM";
  #         devices = [ "pixel" ];
  #       };
  #       pictures = {
  #         id = "pictures";
  #         path = "~/Pictures";
  #         devices = [ "pixel" ];
  #       };
  #       public = {
  #         id = "public";
  #         path = "~/Public";
  #         devices = [ "pixel" ];
  #       };
  #       music = {
  #         id = "music";
  #         path = "~/Music";
  #         devices = [ "pixel" ];
  #       };
  #     };
  #   };
  # };
}
