{ user, ... }:

{
  # Determinate already manages the Nix daemon, so nix-darwin shouldn't.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin"; # use x86_64-darwin for Intel CPU

  system.primaryUser = user;
  users.users.${user} = {
    home = "/Users/${user}";
  };
  system.stateVersion = 6;
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;          # fast key repeat
      InitialKeyRepeat = 15;  # short delay before repeat
      _HIHideMenuBar = false;
      AppleShowAllExtensions = true;
    };
    dock.autohide = false;
    finder.FXPreferredViewStyle = "Nlsv";  # list view by default
    finder.CreateDesktop = false;          # clean desktop
    trackpad.Clicking = true;              # tap to click
  };
  nix-homebrew = {
    autoMigrate = true;
    enable = true;
    inherit user;
  };
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";  # changed to zap to enforce declarative homebrew
    onActivation.autoUpdate = true;
    onActivation.extraFlags = [ "--force" ];
    brews = [
      "herdr"
      "zackelia/formulae/bclm"
    ];
    casks = [
      "wezterm"
      "claude-code"
      "codex"
      "antigravity-cli"
      "visual-studio-code"
      "opensuperwhisper"  # local Whisper dictation, hotkey-triggered
      "blackhole-16ch"    # virtual audio driver, already installed
      "blackhole-2ch"     # virtual audio driver, already installed
    ];
  };
}
