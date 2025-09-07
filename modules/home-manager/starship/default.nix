{ inputs, config, lib, pkgs, ... }:

with lib;

let
  cfg = config.nix-pille.programs.starship;
in
{
  options.nix-pille.programs.starship = {
    enable = mkEnableOption {
      name = "nix pille starship configuration";
    };
  };

  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;

      settings = {
        add_newline = false;
        format = lib.concatStrings [
          "$username"
          "$hostname"
          "$directory"
          "$git_branch"
          "$git_commit"
          "$git_state"
          "$git_metrics"
          "$git_status"
          "$nix_shell"
          "$memory_usage"
          "$cmd_duration"
          "$line_break"
          "$status"
          "$jobs"
          "$character"
        ];
        character = {
          success_symbol = "[❯](bold green)";
          error_symbol = "[❯](bold red)";
        };
        cmd_duration = {
          min_time = 1000;
          style = "yellow";
          format = "[ $duration]($style)";
        };
        directory = {
          style = "blue";
          read_only = " ";
          format = "[$read_only]($read_only_style)[ $path]($style) ";
          truncation_length = 5;
          truncate_to_repo = true;
          repo_root_format = "[$read_only]($read_only_style)[ $repo_root]($repo_root_style)[$path]($style) ";
        };
        git_branch = {
          symbol = " ";
          style = "purple";
          format = "[$symbol$branch(:$remote_branch)]($style) ";
        };
        git_metrics = {
          disabled = false;
        };
        nix_shell = {
          symbol = " ";
          style = "blue";
          format = "[$symbol$state $name]($style) ";
        };
        hostname = {
          ssh_only = true;
          style = "green";
          ssh_symbol = " ";
          format = "[$ssh_symbol$hostname]($style) ";
        };
        memory_usage = {
          symbol = "󰍛 ";
          disabled = false;
          format = "[$symbol$ram( | $swap)]($style) ";
        };
        username = {
          show_always = true;
          format = "[ $user]($style) ";
        };
        status = {
          disabled = false;
          format = "[$common_meaning$signal_name$maybe_int]($style) ";
        };
      };
    };
  };
}
