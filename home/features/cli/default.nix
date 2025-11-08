{ pkgs, ... }: 
  
{

  imports = [
    ./zsh.nix
    ./fzf.nix
    ./neofetch.nix
    ./neovim.nix
    ./tmux.nix
    ./starship.nix
  ];

  programs.eza = { # modern replacement for ls command
    enable = true;
    enableZshIntegration = true;
    icons = "auto";
    git = true;
    extraOptions = [
      "--group-directories-first"
      "--header"
      "--color=auto"
    ];
  };

  programs.zoxide = { # smarter cd command
    enable = true;
    enableZshIntegration = true;
  };

  programs.bat = { # cat clone with syntax highlighting and git integration
    enable = true;
    config = {
      theme = "Nord";
    };
  };

  programs.gpg.enable = true; # GNU Privacy Guard for encryption and signing data

  programs.direnv = { # directory-based environment variable manager
    enable = true;
    nix-direnv.enable = true;
  };

  programs.diff-so-fancy.enableGitIntegration = true; # enhanced git diff viewer

  programs.htop = { # interactive process viewer
    enable = true;
    settings.show_program_path = true;
  };

  programs.lf.enable = true; # terminal file manager

  home.packages = with pkgs; [
    coreutils # basic file, shell and text manipulation utilities
    ripgrep # better grep
    fd # replacing find command
    httpie # user-friendly curl alternative
    jq # JSON query tool
    procs # process viewer
    tldr # simplified help for command-line tools
    zip # file compression 
    eza # modern replacement for  ls 
    dust # disk usage analyzer
  ];
}