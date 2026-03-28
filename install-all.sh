#!/bin/bash
# install-all.sh — installa tutti i comandi claude-skills in ~/.claude/commands/
# Uso: curl -fsSL https://raw.githubusercontent.com/JoWood94/claude-skills/main/install-all.sh | bash

set -e

COMMAND_DIR="$HOME/.claude/commands"
BASE_URL="https://raw.githubusercontent.com/JoWood94/claude-skills/main"

mkdir -p "$COMMAND_DIR"

echo ""
echo "Installing all claude-skills..."
echo ""

install_skill() {
  local name="$1"
  local url="$BASE_URL/$name/$name.md"
  local dest="$COMMAND_DIR/$name.md"

  if command -v curl &>/dev/null; then
    curl -fsSL "$url" -o "$dest"
  elif command -v wget &>/dev/null; then
    wget -q "$url" -O "$dest"
  else
    echo "❌ Error: curl or wget is required."
    exit 1
  fi

  echo "✅ /$name installed"
}

install_skill "multiagent-setup"

echo ""
echo "All skills installed in $COMMAND_DIR"
echo ""
echo "Open any Claude Code session and type /skill-name to use them."
echo ""
