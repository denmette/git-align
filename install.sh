#!/bin/bash

set -e

echo "📦 Installing git-align..."

chmod +x bin/git-align

# Detect brew prefix
if command -v brew >/dev/null; then
  BREW_PREFIX=$(brew --prefix)
  BREW_BIN="$BREW_PREFIX/bin"
else
  BREW_BIN=""
fi

USER_BIN="$HOME/.local/bin"

install_to() {
  DEST="$1"
  mkdir -p "$DEST"
  cp bin/git-align "$DEST/git-align"
  cp VERSION "$DEST/git-align.version"
  echo "✅ Installed to $DEST"
}

# Try Homebrew location first (zonder sudo)
if [ -n "$BREW_BIN" ] && [ -w "$BREW_BIN" ]; then
  install_to "$BREW_BIN"
else
  echo "ℹ️ No write access to Homebrew bin, installing locally"
  install_to "$USER_BIN"

  if [[ ":$PATH:" != *":$USER_BIN:"* ]]; then
    echo ""
    echo "⚠️  $USER_BIN is not in your PATH"
    echo "👉 Add this to ~/.zshrc:"
    echo ""
    echo "export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
  fi
fi

echo "👉 Run: git-align --help"
