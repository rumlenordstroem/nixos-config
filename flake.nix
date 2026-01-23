{
  description = "My NixOS configuration";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Others
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "nixpkgs";
    nix-colors.url = "github:misterio77/nix-colors";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    niri.url = "github:sodiboo/niri-flake";
  };

  outputs = {
    self,
    ...
  } @ inputs: let
    # Supported systems for your flake packages, shell, etc.
    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    forAllSystems = inputs.nixpkgs.lib.genAttrs systems;

    # Custom packages and modifications, exported as overlays
    overlays = import ./overlays { inherit inputs; };

    allPackages = forAllSystems (system: import inputs.nixpkgs {
      inherit system;
      overlays = [
        overlays.additions
        overlays.modifications
        inputs.nur.overlays.default
        inputs.niri.overlays.niri
      ];
      config.allowUnfree = true;
    });

    nixosModules = import ./modules/nixos;

    homeManagerModules = import ./modules/home-manager;

    mkNixosConfiguration = { host, system, extraModules ? [ ] }: inputs.nixpkgs.lib.nixosSystem {
      pkgs = allPackages.${system};
      specialArgs = { inherit inputs; };
      modules = [
        nixosModules
        (./. + "/hosts/${host}")
        (./. + "/shared/${host}")
        inputs.nix-index-database.nixosModules.nix-index
      ] ++ extraModules;
    };

    mkHomeManagerConfiguration = { user, host, system, extraModules ? [ ] }: inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = allPackages.${system};
        extraSpecialArgs = { inherit inputs; };
        modules = [
          homeManagerModules
          (./. + "/homes/${user}@${host}")
          ./shared/${host}
          inputs.niri.homeModules.niri
        ] ++ extraModules;
      };
  in {
    packages = forAllSystems (system: {
      default = self.packages.${system}.iso;
      iso = self.nixosConfigurations.iso.config.system.build.isoImage;
      nixos-vm = allPackages.${system}.writeShellScriptBin "nixos-vm" /* bash */ ''
        ${allPackages.${system}.qemu}/bin/qemu-system-x86_64 -enable-kvm -m 4096 -vga virtio -cdrom ${self.packages.${system}.iso}/iso/${self.nixosConfigurations.iso.config.system.build.isoImage.isoName}
      '';
    });

    apps = forAllSystems (system: {
      default = {
        type = "app";
        program = "${self.packages.${system}.nixos-vm}/bin/nixos-vm";
        meta.description = "Script that runs a virtual machine with ISO.";
      };
    });

    # NixOS configuration entrypoint
    nixosConfigurations = {
      "edb" = mkNixosConfiguration { host = "edb"; system = "x86_64-linux"; };
      "p43s" = mkNixosConfiguration { host = "p43s"; system = "x86_64-linux"; };
      "iso" = mkNixosConfiguration {
        host = "iso";
        system = "x86_64-linux";
        extraModules = [
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs; };
              users.nixos.imports = [
                homeManagerModules
                (./. + "/homes/nixos@iso")
                ./shared/iso
                inputs.niri.homeModules.niri
              ];
            };
          }
        ];
      };
    };

    # Standalone home-manager configuration entrypoint
    homeConfigurations = {
      "rumle@edb" = mkHomeManagerConfiguration { user = "rumle"; host = "edb"; system = "x86_64-linux"; };
      "rumle@p43s" = mkHomeManagerConfiguration { user = "rumle"; host = "p43s"; system = "x86_64-linux"; };
    };
  };
}
