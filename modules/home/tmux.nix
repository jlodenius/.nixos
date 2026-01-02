{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    shortcut = "a";
    baseIndex = 1;
    newSession = true;
    escapeTime = 0;
    mouse = true;

    # This handles the plugin AND the 'run-shell' logic automatically
    plugins = with pkgs; [
      tmuxPlugins.vim-tmux-navigator
    ];

    extraConfig = ''
      # Terminal & Colors
      set -g default-terminal 'tmux-256color'
      set-option -sa terminal-features ',xterm-256color:RGB'
      set-option -g focus-events on

      # Bind å to enter copy-mode
      unbind [
      bind-key å copy-mode

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

      # --- UI / Status Line (Monochrome Style) ---
      set-option -g status-position top
      set -g status-bg black
      set -g status-fg white
      set -g status-left ""
      set -g status-right " #h: #S "

      set -g status-justify left
      set-window-option -g window-status-separator ""
      set-window-option -g window-status-format "#[bg=black,fg=white] #I #W "
      set-window-option -g window-status-current-format "#[bg=brightblack,fg=brightwhite] #I #W "

      # Pane borders & Style
      set -g window-style "bg=default,fg=white"
      set -g window-active-style "bg=default,fg=brightwhite"
      set -g pane-border-style "bg=default,fg=black"
      set -g pane-active-border-style "bg=default,fg=black"
    '';
  };
}
