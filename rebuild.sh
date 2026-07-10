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
exec sudo darwin-rebuild switch --flake ~/.dotfiles#mac
