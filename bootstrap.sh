#!/usr/bin/env bash
# Takes a fresh machine from nothing to a built config.
# Mac: nix-darwin + home-manager. Linux: standalone home-manager.
# Run this once. After it finishes, use ./rebuild.sh for every later change.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
OS="$(uname -s)"

echo "==> Step 1: Determinate Nix"
if command -v nix >/dev/null 2>&1; then
  echo "    nix already installed, skipping"
else
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    | sh -s -- install --no-confirm
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

echo "==> Step 2: symlink this repo to ~/.dotfiles"
# home.nix resolves mkOutOfStoreSymlink paths through ~/.dotfiles (nvim, wezterm,
# AGENTS.md, etc.), so this must exist before the first switch.
# Agent files (AGENTS.md, CLAUDE.md, ...) are installed only by home-manager;
# do not pre-link them here or HM will fight the scripts on every switch.
ln -sfn "$DIR" ~/.dotfiles

echo "==> Step 3: personalize the configured username"
# Do this before any sudo call: sudo resets $USER to root, so whoami has to
# run as the real interactive user first.
REAL_USER="$(whoami)"
FLAKE_USER="$(sed -nE 's/^[[:space:]]*user = "([^"]+)";.*/\1/p' "$DIR/flake.nix" | head -n1)"
if [ -z "$FLAKE_USER" ]; then
  echo "    Could not find the single \"user = \" line in flake.nix."
  echo "    Edit flake.nix yourself before continuing."
  exit 1
elif [ "$FLAKE_USER" != "$REAL_USER" ]; then
  echo "    flake.nix is configured for user \"$FLAKE_USER\", but you are \"$REAL_USER\"."
  read -r -p "    Rewrite flake.nix's \"user = \" line to \"$REAL_USER\"? [y/N] " REPLY
  if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
    # macOS sed needs -i '', GNU sed needs -i (no empty backup suffix).
    if [ "$OS" = "Darwin" ]; then
      sed -i '' -E "s/^([[:space:]]*user = \")[^\"]+(\";.*)/\1${REAL_USER}\2/" "$DIR/flake.nix"
    else
      sed -i -E "s/^([[:space:]]*user = \")[^\"]+(\";.*)/\1${REAL_USER}\2/" "$DIR/flake.nix"
    fi
    echo "    Updated. Review the change with: git diff flake.nix"
  else
    echo "    Skipped. Edit the single \"user = \" line in flake.nix yourself before continuing."
    exit 1
  fi
else
  echo "    flake.nix already matches \"$REAL_USER\", nothing to do."
fi

NIX_BIN="$(command -v nix)"

case "$OS" in
  Darwin)
    echo "==> Step 4: first darwin-rebuild switch (pinned to nix-darwin-26.05)"
    # darwin-rebuild doesn't exist yet on a fresh machine, so run it straight
    # from the flake this once. After this, rebuild.sh works normally.
    # This fetches the darwin-rebuild tool from the nix-darwin-26.05 release branch,
    # not the exact flake.lock revision. The system config it applies is still pinned
    # by this repo's flake.lock.
    # sudo resets PATH to a secure default that excludes /nix/.../bin, so a
    # freshly installed `nix` would not be found under sudo even though it's
    # on PATH here. Resolve the absolute path first and invoke that instead.
    # "mac" is the flake host label - if you renamed it, change it in flake.nix
    # and rebuild.sh too.
    sudo "$NIX_BIN" run github:nix-darwin/nix-darwin/nix-darwin-26.05#darwin-rebuild -- \
      switch --flake ~/.dotfiles#mac
    # If this still fails with "nix: command not found", open a new terminal
    # (Determinate adds nix to new shells' PATH) and re-run ./bootstrap.sh.
    ;;
  Linux)
    echo "==> Step 4: first home-manager switch (pinned to release-26.05)"
    # home-manager may not be on PATH yet; run it from the release branch once.
    # Flake attr is the username from flake.nix (default x86_64-linux).
    # On aarch64 Linux, use #${REAL_USER}-aarch64 instead (see flake.nix).
    ARCH="$(uname -m)"
    case "$ARCH" in
      aarch64|arm64) HM_ATTR="${REAL_USER}-aarch64" ;;
      *)             HM_ATTR="${REAL_USER}" ;;
    esac
    # -b hm-backup: move colliding existing files aside (same extension as Mac).
    "$NIX_BIN" run home-manager/release-26.05 -- switch -b hm-backup --flake ~/.dotfiles#"${HM_ATTR}"
    ;;
  *)
    echo "Unsupported OS: $OS (expected Darwin or Linux)"
    exit 1
    ;;
esac

echo "==> Done. Use ./rebuild.sh for future changes."
