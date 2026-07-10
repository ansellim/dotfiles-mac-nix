# dotfiles

Watch the walkthrough: https://youtu.be/5N-okeDdIuI

Personal setup managed with Nix: **nix-darwin + home-manager on Mac**, and **standalone home-manager on Linux**.
One repo, one bootstrap command, and a fresh machine ends up with the same shell, editor, and agent config.

## Contributing / Using This Repo

These are personal dotfiles, shared publicly so people can read them, learn from them, and fork them freely.
Feature requests and pull requests are not accepted here, and PRs are auto-closed.
If you find a bug, please open a GitHub Issue using the bug report template.

## What you get

### Shared (Mac and Linux)

Running the switch builds:

- Nix user packages (ripgrep, fd, fzf, jq, lazygit, Neovim, Node.js, Hack Nerd Font)
- WezTerm on Linux via Nix (on Mac it comes from Homebrew)
- Shell (zsh, aliases, starship prompt)
- Editor (Neovim config)
- Terminal (WezTerm config)
- Session manager (tmux, mouse mode on)
- Agent configs (Claude, Codex, opencode, Grok all share one AGENTS.md)
- `npx skills` works out of the box (Node.js is installed) for managing agent skills

### Mac only

- System settings (dark mode, key repeat, dock, Finder, trackpad)
- Homebrew apps (casks and CLI tools, including OpenSuperWhisper for local voice dictation)

## Prerequisites

### Mac

- Apple Silicon Mac, by default.
- Intel Mac: change one line.
  In `configuration.nix`, set `nixpkgs.hostPlatform = "x86_64-darwin";` (the comment right there tells you the same thing).

### Linux

- x86_64 or aarch64.
- No NixOS required; standalone home-manager is enough.
- aarch64: bootstrap/rebuild pick the `username-aarch64` flake attribute automatically.

## Fresh-machine setup

From a bare clone of this repo:

```sh
git clone https://github.com/kunchenguid/dotfiles.git
cd dotfiles
```

Before you run it: review "Make it yours" below.
Change the host label or CPU architecture if needed, and on Mac read the Homebrew cleanup warning.
`bootstrap.sh` applies the config to your machine, so do this first.

```sh
./bootstrap.sh
```

`bootstrap.sh` does four things, in order:

1. Installs Determinate Nix, if it isn't already installed.
2. Symlinks this repo to `~/.dotfiles`.
   This has to happen before the first build, because `home.nix` points at config files through `~/.dotfiles`.
3. Checks the `user` configured in `flake.nix` against your actual username, and offers to fix it for you if they differ.
4. Runs the first switch:
   - **Mac:** `darwin-rebuild switch` (fetches the tool from the nix-darwin 26.05 release branch, then applies this repo's locked flake config).
   - **Linux:** `home-manager switch` against the flake attr for your username (and arch).

After that, you're on the normal workflow below.

### Validate without applying

Once Nix is installed (`bootstrap.sh` step 1 handles that), you can check that the config builds without touching your system - handy when you have edited something:

```sh
nix flake check --no-build
# Mac:
nix build .#darwinConfigurations.mac.system --dry-run
# Linux (replace ansel with your username if needed):
nix build .#homeConfigurations.ansel.activationPackage --dry-run
```

If you renamed the host label in "Make it yours", substitute your label for `mac` in these commands.

## Daily use

Edit the config files in place, then apply:

```sh
./rebuild.sh
```

That's it.
No separate build-and-copy step.
`rebuild.sh` detects Darwin vs Linux and runs the right switch command.

## Make it yours

This repo is mine.
If you clone it, review these before you run `bootstrap.sh`:

- **Username**: run `./bootstrap.sh` (it detects your username and offers to set it) OR change the single `user = "ansel"` line in `flake.nix`.
  Everything else (`configuration.nix`, `home.nix`, home directory paths) is threaded from that one variable.
- **Host label** `"mac"` (Mac only), in three places: `flake.nix` (the `darwinConfigurations."mac"` name), `rebuild.sh` (the `#mac` flake ref), and `bootstrap.sh`'s first-switch command (also `#mac`).
  All three have to match.
- **CPU architecture (Mac)**: `hostPlatform` in `configuration.nix` (see Prerequisites above).
- **CPU architecture (Linux)**: default flake attr is `x86_64-linux` under `homeConfigurations.<user>`; aarch64 uses `<user>-aarch64`. Scripts pick this from `uname -m`.

**Git identity:** this config deliberately does not set your git name or email.
Git will stop your first commit and tell you to set them (`git config --global user.name "Your Name"` and `git config --global user.email you@example.com`).
If you'd rather manage that declaratively, add this back to `home.nix` with your own identity:

```nix
programs.git = {
  enable = true;
  settings.user = {
    name = "Your Name";
    email = "you@example.com";
  };
};
```

**Homebrew cleanup warning (Mac only):** `configuration.nix` sets `homebrew.onActivation.cleanup = "zap"`.
That means every time you switch, Homebrew removes any package or cask on your machine that isn't listed in the `brews` and `casks` arrays in `configuration.nix`.
If you already have Homebrew stuff installed that isn't in that list, the first switch will uninstall it.
Read through `brews` and `casks` before you run `bootstrap.sh` or `rebuild.sh` for the first time, and add anything you want to keep.

**About `herdr`:** it's in the Mac `brews` list.
It's a real public Homebrew formula (`brew info herdr` finds it in homebrew-core, no tap needed), so it will install fine on Mac.
If you don't use it, just remove it from `brews` in your copy.

**Heads-up:**

- `home/AGENTS.md` is personal agent policy, and `home.nix` installs it for Claude, Codex, opencode, and Grok.
  If you clone this repo, you'd silently inherit those agent instructions - edit or delete `home/AGENTS.md` if you don't want that.
- The `cc` and `co` shell aliases in `home.nix` are high-agency shortcuts: `claude --dangerously-skip-permissions` and `codex --full-auto`.
  They're convenient for me, but know what they do before you use them.

## Repo tour

- `flake.nix` - the entry point.
  Wires up nixpkgs, nix-darwin, home-manager, and nix-homebrew; declares the `mac` Darwin machine and Linux `homeConfigurations`.
- `configuration.nix` - Mac system-level config: macOS defaults, Homebrew. Not used on Linux.
- `home.nix` - user-level config shared by Mac and Linux: shell, packages, prompt, and the symlinks described below.
- `rebuild.sh` - re-applies the config after the first switch (auto-detects OS).
  Run this every time you make a change.
- `home/` - the actual config files that get symlinked into place (Neovim, WezTerm, herdr, Claude settings, the shared `AGENTS.md`).

## How the symlinks work

The files under `home/` are the real files - editing them here is editing your live config, no rebuild needed to see the change in your editor.
`home.nix` uses `mkOutOfStoreSymlink` to point paths like `~/.config/nvim` straight at `home/.config/nvim` in this repo, so the two never drift out of sync.
You only run `./rebuild.sh` when you change something that isn't just a symlinked file, like a package list or a system default.

## Notes

The first time you launch `nvim`, it bootstraps [lazy.nvim](https://github.com/folke/lazy.nvim) by cloning plugins from GitHub.
That needs network access once; after that it's offline.

After changing flake inputs (for example switching nixpkgs channels), run `nix flake update` before the next switch so `flake.lock` matches.

## License

This repo is licensed under MIT No Attribution.
See `LICENSE`.
