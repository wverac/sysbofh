{pkgs, ...}: {
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
}
