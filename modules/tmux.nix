{...}: {
  flake.nixosModules.tmux = {
    config,
    pkgs,
    ...
  }: let
    c = config.colours;
  in {
    home-manager.users.jacob = {pkgs, ...}: {
      programs.tmux = {
        enable = true;
        keyMode = "vi";
        prefix = "C-a";
        baseIndex = 1;
        escapeTime = 0;
        mouse = true;
        terminal = "tmux-256color";
        plugins = with pkgs; [
          tmuxPlugins.vim-tmux-navigator
          (tmuxPlugins.mkTmuxPlugin {
            pluginName = "tmux-scrollback";
            rtpFilePath = "scrollback.tmux";
            version = "unstable";
            src = fetchFromGitHub {
              owner = "jlodenius";
              repo = "tmux-scrollback";
              rev = "master";
              sha256 = "sha256-Z2vD/lEoHRgp7aCMaB44XeicgBb2SZ3b6YkAY/952u4=";
            };
          })
        ];
        extraConfig = ''
          set-option -sa terminal-features ',xterm-256color:RGB'
          set-option -g focus-events on

          # Bind å to enter copy-mode
          unbind [
          bind-key å copy-mode

          # Vim-like copy mode bindings
          bind-key -T copy-mode-vi v send-keys -X begin-selection
          bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

          # Split windows & open in current path
          unbind %
          bind | split-window -h -c "#{pane_current_path}"
          unbind '"'
          bind - split-window -v -c "#{pane_current_path}"
          bind c new-window -c "#{pane_current_path}"

          # Vim-like pane switching
          bind -r k select-pane -U
          bind -r j select-pane -D
          bind -r h select-pane -L
          bind -r l select-pane -R

          # Vim-like pane resizing
          bind -r C-k resize-pane -U 5
          bind -r C-j resize-pane -D 5
          bind -r C-h resize-pane -L 5
          bind -r C-l resize-pane -R 5

          # Maximise pane
          bind -r m resize-pane -Z

          # Status line
          set-option -g status-position top
          set -g status-bg "${c.background}"
          set -g status-fg "${c.foreground}"
          set -g status-left ""
          set -g status-right " #h: #S "
          set -g status-justify left
          set-window-option -g window-status-separator ""
          set-window-option -g window-status-format "#[bg=${c.background},fg=${c.comment}] #I #W "
          set-window-option -g window-status-current-format "#[bg=${c.surface},fg=${c.foreground}] #I #W "

          # Pane borders
          set -g window-style "bg=default,fg=${c.comment}"
          set -g window-active-style "bg=default,fg=${c.foreground}"
          set -g pane-border-style "bg=default,fg=${c.surface}"
          set -g pane-active-border-style "bg=default,fg=${c.surface}"
        '';
      };
    };
  };
}
