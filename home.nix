{ config, pkgs, lib, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
  homeDir =
    if pkgs.stdenv.isDarwin
    then "/Users/${user}"
    else "/home/${user}";
in

{
  home.username = user;
  home.homeDirectory = homeDir;
  home.stateVersion = "24.11";
  # Standalone home-manager (Linux): back up colliding files instead of aborting.
  # On Mac, flake.nix also sets home-manager.backupFileExtension for nix-darwin.
  home.backupFileExtension = "hm-backup";
  home.packages = with pkgs; [
    # cli i use constantly
    ripgrep   # fast search
    fd        # fast find
    fzf       # fuzzy finder
    jq        # json on the command line
    lazygit
    neovim
    nodejs    # gives npm/npx, e.g. `npx skills` for agent skill management
    # the font everything renders in
    nerd-fonts.hack
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    # On Mac these come from Homebrew casks in configuration.nix.
    wezterm
  ];
  fonts.fontconfig.enable = true;
  # Install the home-manager CLI into the user profile (standalone Linux).
  # On Mac, darwin-rebuild owns activation; the CLI is optional there.
  programs.home-manager.enable = pkgs.stdenv.isLinux;
  home.sessionVariables.EDITOR = "nvim";
  home.sessionVariables.CLAUDE_HOOK = "/usr/bin/true";

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;      # ghost text from history
    syntaxHighlighting.enable = true;  # commands turn green when valid
    initContent = ''
      bindkey '^f' autosuggest-accept
    '';
    shellAliases = {
      ".." = "cd ..";
      add = "git add .";
      push = "git push";
      pull = "git pull";
      m = "git switch main";
      cc = "claude --dangerously-skip-permissions";
      co = "codex --full-auto";
    };
  };

  programs.tmux = {
    enable = true;
    mouse = true;         # click to switch panes, drag to resize
    baseIndex = 1;        # windows/panes numbered from 1, not 0
    escapeTime = 0;       # no lag on esc in nvim
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      command_timeout = 5000;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
      };
      cmd_duration.format = "[$duration]($style) ";
    };
  };

  # Edit-in-place: the real file stays in my repo, ~/.config just points at it.
  home.file.".config/wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/wezterm";
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
  home.file.".config/herdr".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr";
  home.file.".claude/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/settings.json";

  home.file."AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";

  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".config/opencode/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".grok/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
}
