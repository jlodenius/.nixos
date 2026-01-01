{
  config,
  pkgs,
  zen-browser,
  ...
}: {
  imports = [
    ./modules/tmux.nix
    ./modules/fish.nix
  ];

  home.username = "jacob";
  home.homeDirectory = "/home/jacob";
  home.stateVersion = "25.11";

  xdg.userDirs = {
    enable = true;
    createDirectories = true;

    # Create these
    download = "${config.home.homeDirectory}/Downloads";
    documents = "${config.home.homeDirectory}/Documents";
    pictures = "${config.home.homeDirectory}/Pictures";

    # And ignore these
    desktop = "${config.home.homeDirectory}";
    music = "${config.home.homeDirectory}";
    videos = "${config.home.homeDirectory}";
    templates = "${config.home.homeDirectory}";
    publicShare = "${config.home.homeDirectory}";
  };

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    GPG_TTY = "$(tty)";

    # XDG & Desktop
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CURRENT_DESKTOP = "Hyprland";

    # App specific
    AWS_PROFILE = "caesari-authentik-saml";
  };

  home.sessionPath = [
    "$HOME/.cargo/bin"
    "$HOME/.local/bin"
  ];

  home.packages = with pkgs; [
    # System & UI
    ghostty
    waybar
    swww
    vicinae
    bluetuith
    stow
    grim
    slurp

    # Dev tools
    gh
    rustup
    alejandra
    gcc
    gnumake
    cmake

    # CLI utils
    ripgrep
    fd
    yazi

    # Applications
    google-chrome
    discord
    zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "jlodenius";
        email = "jacoblodenius@gmail.com";
      };
      init.defaultBranch = "master";
    };
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    options = ["--cmd cd"];
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.fzf.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
