{
  pkgs,
  inputs,
  ...
}: {
  home.username = "wvera";
  home.homeDirectory = "/Users/wvera";

  home.packages = with pkgs; [
    starship
    inputs.nixvim.packages.${pkgs.stdenv.hostPlatform.system}.default
    git
    # vim
    gotop
    wget
    curl
    fastfetch
    # docker
    # docker-compose
    ollama
    claude-code
    bash
    sshuttle
    cloudflared
    autossh
  ];

  programs.git.settings = {
    enable = true;
    user.name = "William Vera";
    user.email = "wv@linux.com";
    init.defaultBranch = "main";
  };

  # Bash configuration moved to darwin-fixes.nix module
  # programs.bash = {
  #   enable = true;
  #   enableCompletion = true;
  #   shellAliases = {
  #     cat = "bat --paging=never";
  #     lcat = "bat --style=plain --paging=never";
  #     ls = lib.mkForce "lsd";
  #     ll = lib.mkForce "lsd -latrh";
  #     vim = lib.mkForce "nvim";
  #   };
  #   bashrcExtra = ''
  #     # Use modern bash features with Nix bash
  #     eval "$(fzf --bash)"
  #   '';
  # };

  programs.starship = {
    enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  news.display = "silent";

  imports = [
    ../../modules/home/fastfetch.nix
    # ../../modules/home/tmux.nix #FIX:wtf?
    ../../modules/home/darwin-fixes.nix
    ../../modules/home/bofhbash.nix
    # ../../modules/home/vim.nix #FIX: conflicts with nixvim
  ];

  home.stateVersion = "25.05";
}
