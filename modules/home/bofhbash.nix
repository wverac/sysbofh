{
  pkgs,
  config,
  lib,
  ...
}: let
  isDarwin = pkgs.stdenv.isDarwin;
in {
  # sysBOFH
  programs.bat.enable = true;
  programs.lsd.enable = true;
  programs.fzf.enableBashIntegration = true;

  home.packages = with pkgs; [
    fzf
  ] ++ lib.optionals (!isDarwin) [
    blesh  # Only install blesh on non-Darwin systems
  ];

  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      cat = "bat --paging=never";
      lcat = "bat --style=plain --paging=never";
      ls = lib.mkForce "lsd";
      ll = lib.mkForce "lsd -latrh";
    };
    bashrcExtra = lib.optionalString (!isDarwin) ''
      # Only configure blesh on non-Darwin systems
      if [[ -s "${pkgs.blesh}/share/blesh/ble.sh" ]]; then
        source "${pkgs.blesh}/share/blesh/ble.sh"
      fi
    '' + ''
      eval "$(fzf --bash)"
    '';
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      # NOTE: Moved to left side
      #right_format = "$custom";
      format = builtins.concatStringsSep "" [
        "$username"
        "$hostname"
        "$directory"
        "$kubernetes"
        "$nix_shell"
        "$python"
        "$docker_context"
        "$git_branch"
        "$git_state"
        "$git_status"
        "$cmd_duration"
        "$custom"
        "$character"
      ];
      custom.vpn_script = lib.mkIf (!isDarwin) {
        command = "${config.home.homeDirectory}/.config/scripts/check-vpn.sh";
        format = "[$output]($style)";
        style = "green";
        when = "hostname | grep -qE '^(nixlab|nabucodonosor)$'";
      };
      username = {
        format = "[$user]($style)";
        show_always = true;
        style_user = "gray bold";
      };
      hostname = {
        ssh_only = false;
        ssh_symbol = "";
        format = "@[$hostname](white bold) [$ssh_symbol](red bold)";
      };

      directory = {
        read_only = " 󰌾";
        style = "blue";
      };
      docker_context = {
        symbol = " ";
      };
      git_branch = {
        symbol = " ";
      };
      golang = {
        symbol = " ";
      };
      lua = {
        symbol = " ";
      };
      memory_usage = {
        symbol = "󰍛 ";
      };
      nix_shell = {
        symbol = " ";
      };
      nodejs = {
        symbol = " ";
      };
      package = {
        symbol = "󰏗 ";
      };
      python = {
        symbol = " ";
      };
    };
  };
  
  # Only create VPN check script on non-Darwin systems
  home.file.".config/scripts/check-vpn.sh" = lib.mkIf (!isDarwin) {
    source = ../../modules/home/config/scripts/mullvad.sh;
  };
}
