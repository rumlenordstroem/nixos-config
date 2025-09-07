{ inputs, config, lib, pkgs, ... }:

with lib;

let
  cfg = config.nix-pille.cli;
in
{
  options.nix-pille.cli = {
    enable = mkEnableOption "Commonly used CLI tools";
  };

  config = mkIf cfg.enable {
    nix-pille.programs = {
      bat.enable = true;        # Terminal file viewer
      eza.enable = true;        # Modern ls
      fish.enable = true;       # Shell
      fzf.enable = true;        # Fuzzy finder
      git.enable = true;        # VCS
      helix.enable = true;      # Text editor
      starship.enable = true;   # Shell prompt
      tokei.enable = true;      # Source code counter
    };

    programs = {
      fd.enable = true;         # Modern find
      htop.enable = true;       # System monitor
      ripgrep.enable = true;    # Modern grep
    };

    home.packages = with pkgs; [
      hexyl                     # Hexdumper
      gdu                       # Disk usage analyzer
      file                      # File type analyzer
      tldr                      # Alternative to man pages
      fq                        # Binary file analyzer
    ];
  };
}
