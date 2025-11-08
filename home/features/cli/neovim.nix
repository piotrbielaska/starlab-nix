{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.neovim;
  in {
    options.features.cli.neovim.enable = mkEnableOption "Neovim enhancements and plugins";

    config = mkIf cfg.enable {
      programs.neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;
        plugins = with pkgs.vimPlugins; [
          ## regular
          comment-nvim
          lualine-nvim
          nvim-web-devicons
          vim-tmux-navigator

          ## with config
          {
            plugin = gruvbox-nvim;
            config = "colorscheme gruvbox";
          }

          {
            plugin = catppuccin-nvim;
            config = "colorscheme catppuccin";
          }

          ## telescope
          {
            plugin = telescope-nvim;
            type = "lua";
            config = builtins.readFile ./nvim/plugins/telescope.lua;
          }
          telescope-fzf-native-nvim

        ];
        extraLuaConfig = ''
          ${builtins.readFile ./nvim/options.lua}
          ${builtins.readFile ./nvim/keymap.lua}
        '';
      };
    };
  };
}