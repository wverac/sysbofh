{
  pkgs,
  config,
  ...
}: {
  # sysBOFH
  programs.bat.enable = true;
  programs.lsd.enable = true;
  programs.fzf.enableBashIntegration = true;

  home.packages = with pkgs; [
    blesh
    fzf
  ];

  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      cat = "bat --paging=never";
      lcat = "bat --style=plain --paging=never";
      ls = "lsd";
      ll = "lsd -latrh";
    };
    bashrcExtra = ''
      if [[ -s "${pkgs.blesh}/share/blesh/ble.sh" ]]; then
        source "${pkgs.blesh}/share/blesh/ble.sh"
      fi
      eval "$(fzf --bash)"
    '';
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      right_format = "$custom";
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
        "$character"
      ];
      custom.vpn_script = {
        command = "${config.home.homeDirectory}/.config/scripts/check-vpn.sh";
        format = "[$output]($style)";
        style = "bold green";
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
  home.file.".config/scripts/check-vpn.sh" = {
    source = ../../modules/home/config/scripts/check-vpn.sh;
  };
}
