#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ln -sfn "$DIR" ~/.dotfiles
mkdir -p ~/.claude ~/.codex ~/.config/opencode ~/.grok
ln -sfn ~/.dotfiles/home/AGENTS.md ~/AGENTS.md
ln -sfn ~/.dotfiles/home/AGENTS.md ~/.claude/CLAUDE.md
ln -sfn ~/.dotfiles/home/AGENTS.md ~/.codex/AGENTS.md
ln -sfn ~/.dotfiles/home/AGENTS.md ~/.config/opencode/AGENTS.md
ln -sfn ~/.dotfiles/home/AGENTS.md ~/.grok/AGENTS.md

OS="$(uname -s)"
case "$OS" in
  Darwin)
    # "mac" is the flake host label - keep in sync with flake.nix and bootstrap.sh.
    exec sudo darwin-rebuild switch --flake ~/.dotfiles#mac
    ;;
  Linux)
    # Flake attr is the username from flake.nix (default x86_64-linux).
    # On aarch64 Linux the attr is "${USER}-aarch64".
    USERNAME="$(whoami)"
    ARCH="$(uname -m)"
    case "$ARCH" in
      aarch64|arm64) HM_ATTR="${USERNAME}-aarch64" ;;
      *)             HM_ATTR="${USERNAME}" ;;
    esac
    if command -v home-manager >/dev/null 2>&1; then
      exec home-manager switch -b hm-backup --flake ~/.dotfiles#"${HM_ATTR}"
    else
      # Fallback if home-manager isn't on PATH yet (e.g. first shell after bootstrap).
      exec nix run home-manager/release-26.05 -- switch -b hm-backup --flake ~/.dotfiles#"${HM_ATTR}"
    fi
    ;;
  *)
    echo "Unsupported OS: $OS (expected Darwin or Linux)"
    exit 1
    ;;
esac
