{ config, pkgs, lib, ... }:

{
  home.sessionVariables = {
    BROWSER = "brave";
    EDITOR = "nvim";
    NIXPKGS_ALLOW_UNFREE = "1";
  };

  programs = {
    git.enable = true;

    zoxide = {
      enable = true;
      enableBashIntegration = true;
      options = [ "--cmd cd" ];
    };

    bash.enable = true;
    readline = {
      enable = true;
      variables = {
        "editing-mode" = "vi";
      };
    };

    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };

    btop = {
      enable = true;
      settings = {
        proc_tree = true;
        shown_boxes = "proc cpu mem net gpu0";
      };
    };

    tmux = {
      enable = true;
      mouse = true;
      focusEvents = true;
      escapeTime = 100;
      terminal = "screen-256color";
    };

    kitty = {
      enable = true;
      settings = {
        confirm_os_window_close = 0;
        shell = "sh -c \"tmux has-session -t main 2>/dev/null && exec tmux new-session -t main \\\\; new-window || exec tmux new-session -s main \\\"ssh-agent $SHELL\\\"\"";
      };
      quickAccessTerminalConfig = {
        edge = "center-sized";
      };
    };
  };

  home.packages = with pkgs; [
    # LLM file context utility
    (pkgs.writeShellScriptBin "ct" "for file in \"$@\"; do echo \"$file\"; echo '```'; cat \"$file\"; echo; echo '```'; done")

    # --user only flatpak
    (pkgs.writeShellScriptBin "flatpak" ''
      exec ${lib.getExe pkgs.flatpak} --user "$@"
    '')

    # general cli tools
    bat
    brightnessctl
    cbonsai
    cmatrix
    compsize
    cowsay
    dust
    fastfetch
    fd
    ffmpeg
    figlet
    file
    fortune
    fuse-overlayfs
    fzf
    gale
    gamemode
    git-filter-repo
    htop
    killall
    libqalculate
    llama-cpp-rocm
    lolcat
    nh
    nix-index
    nix-search-cli
    nixfmt
    nodejs
    nvimpager
    p7zip-rar
    pcmanfm
    pipes
    protege-distribution
    python3
    qdirstat
    ripgrep
    tealdeer
    tokei
    tree
    tree-sitter
    unzip
    uv
    wget
    wtf
    zip
  ];
}
