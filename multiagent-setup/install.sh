#!/bin/bash
# install.sh — installa il comando /multiagent-setup in Claude Code
# Uso: curl -fsSL https://raw.githubusercontent.com/JoWood94/claude-skills/main/multiagent-setup/install.sh | bash

set -e

COMMAND_DIR="$HOME/.claude/commands"
COMMAND_FILE="$COMMAND_DIR/multiagent-setup.md"
SOURCE_URL="https://raw.githubusercontent.com/JoWood94/claude-skills/main/multiagent-setup/multiagent-setup.md"

echo ""
echo "Installing /multiagent-setup for Claude Code..."
echo ""

# Crea la directory se non esiste
mkdir -p "$COMMAND_DIR"

# Scarica il file comando
if command -v curl &>/dev/null; then
  curl -fsSL "$SOURCE_URL" -o "$COMMAND_FILE"
elif command -v wget &>/dev/null; then
  wget -q "$SOURCE_URL" -O "$COMMAND_FILE"
else
  echo "❌ Error: curl or wget is required."
  exit 1
fi

echo "✅ Installed: $COMMAND_FILE"
echo ""
echo "Usage: open any Claude Code session and type"
echo "  /multiagent-setup"
echo ""
