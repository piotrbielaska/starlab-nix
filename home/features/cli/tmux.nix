{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.tmux;
  in {
    options.features.cli.tmux.enable = mkEnableOption "Tmux enhancements and plugins";

    config = mkIf cfg.enable {
      programs.tmux = {
        enable = true;
        keyMode = "vi";
        clock24 = true;
        historyLimit = 9999999;
        mouse = true;
        plugins = with pkgs.tmuxPlugins; [
          gruvbox
        vim-tmux-navigator
        sensible
        ];
        extraConfig = ''
          # remap prefix from 'C-b' to 'C-a'
          unbind C-b
          set-option -g prefix C-a
          bind-key C-a send-prefix

          # split panes using | and -
          bind | split-window -h
          bind - split-window -v
          unbind '"'
          unbind %

          # reload config file
          bind r source-file ~/.config/tmux/tmux.conf \; display-message "~/.config/tmux/tmux.conf reloaded."
        
          # switch panes using Alt-arrow without prefix
          bind -n M-Left select-pane -L
          bind -n M-Right select-pane -R
          bind -n M-Up select-pane -U
          bind -n M-Down select-pane -D

          # switch windows using Shift-arrow without prefix
          bind -n S-Left previous-window
          bind -n S-Right next-window

          # don't rename windows automatically
          set-option -g allow-rename off

          # rename window to reflect current program
          setw -g automatic-rename on

          # renumber windows when a window is closed
          set -g renumber-windows on

          # don't do anything when a 'bell' rings
          set -g visual-activity off
          set -g visual-bell off
          set -g visual-silence off
          setw -g monitor-activity off
          set -g bell-action none

          # clock mode
          setw -g clock-mode-colour yellow

          # copy mode
          setw -g mode-style 'fg=black bg=yellow bold'

          # panes
          set -g pane-border-style 'fg=yellow'
          set -g pane-active-border-style 'fg=green'

          # statusbar
          set -g status-position top
          set -g status-justify left
          set -g status-style 'fg=green'
          set -g status-left ""
          set -g status-left-length 10
          set -g status-right '#[fg=green,bg=default,bright]#(tmux-mem-cpu-load) #[fg=red,dim,bg=default]#(uptime | cut -f 4-5 -d " " | cut -f 1 -d ",") #[fg=white,bg=default]%a%l:%M:%S %p#[default] #[fg=blue]%Y-%m-%d'

          setw -g window-status-current-style 'fg=black bg=green'
          setw -g window-status-current-format ' #I #W #F '
          setw -g window-status-style 'fg=green bg=black'
          setw -g window-status-format ' #I #[fg=white]#W #[fg=yellow]#F '
          setw -g window-status-bell-style 'fg=black bg=yellow bold'

          # messages
          set -g message-style 'fg=black bg=yellow bold'

          # start new session
          new-session -s main
        '';
      };
    };
  }