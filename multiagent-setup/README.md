# /multiagent-setup — Claude Code Skill

A Claude Code slash command that sets up a **real multi-agent system** using Claude Code + tmux.

No fake role-playing. Each agent is a separate Claude Code instance in its own terminal window, coordinated via file watchers.

## What it does

Guides you through an interactive setup that:

1. Asks how many agents you need and their roles
2. Checks/installs tmux automatically
3. Generates all context files for each agent
4. Generates file watcher scripts (Node.js, zero dependencies)
5. Generates a `start-team.sh` launcher
6. Optionally launches the full tmux session immediately

## How it works

```
You → Team Lead (Claude Code)
         ↓ writes agents/inbox/alpha.md
      file watcher detects change
         ↓ tmux send-keys injects prompt
      Agent Alpha (separate Claude Code instance)
         ↓ works, updates agents/state/task.md
      file watcher detects response
         ↓ notifies Team Lead
      You ← Team Lead reports result
```

## Requirements

- [Claude Code](https://claude.ai/code) installed
- macOS (uses tmux + Homebrew)
- Node.js (for file watcher scripts)
- tmux (auto-installed if missing)

## Install

**One-liner:**
```bash
curl -fsSL https://raw.githubusercontent.com/JoWood94/claude-skills/main/multiagent-setup/install.sh | bash
```

**Manual:**
```bash
mkdir -p ~/.claude/commands
curl -fsSL https://raw.githubusercontent.com/JoWood94/claude-skills/main/multiagent-setup/multiagent-setup.md \
  -o ~/.claude/commands/multiagent-setup.md
```

## Usage

Open any Claude Code session and type:
```
/multiagent-setup
```

Claude will guide you step by step. The whole setup takes ~2 minutes.

### Smart resume — works on existing projects too

If the current directory already has an `agents/` folder configured, the command detects it automatically and asks:

- **Resume** — relaunch the tmux session with the existing config (agents were already set up)
- **Update** — add/remove agents or change roles without starting from scratch
- **Reset** — overwrite everything and start fresh

This means you can use `/multiagent-setup` both for first-time setup and to re-attach after a reboot or a new terminal session.

## After setup

```bash
# Launch the agent team
bash agents/scripts/start-team.sh

# Attach to the tmux session (use Terminal.app, not VS Code)
tmux attach -t your-project-name

# Send a task to an agent (from Team Lead terminal)
node agents/scripts/send-task.js alpha "Implement the login form"
```

## tmux shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+B` + number | Switch to window N |
| `Ctrl+B` + `W` | List all windows |
| `Ctrl+B` + `D` | Detach (keeps running) |
| `Ctrl+B` + `[` | Scroll mode (q to exit) |

> ⚠️ tmux shortcuts don't work inside VS Code's integrated terminal. Use Terminal.app or any external terminal.

## File structure generated

```
agents/
├── README.md
├── context/
│   ├── team-lead.md      # Team Lead onboarding
│   ├── alpha.md          # Agent Alpha onboarding
│   └── ...               # One file per agent
├── inbox/
│   ├── alpha.md          # Team Lead writes here to assign tasks
│   └── alpha.response.md # Agent writes here when done
├── state/
│   └── {task-id}.md      # Task status files
└── scripts/
    ├── start-team.sh     # Launch full tmux session
    ├── watch-agent.js    # File watcher for each agent
    ├── watch-lead.js     # File watcher for Team Lead
    └── send-task.js      # CLI helper to assign tasks
```

## License

MIT — free to use, share, and modify.
