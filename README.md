# claude-skills

A collection of slash commands and reusable skills for [Claude Code](https://claude.ai/code).

Install any skill in one line and invoke it directly inside Claude Code with `/skill-name`.

---

## Available Skills

### `/multiagent-setup`

Set up a **real multi-agent system** using Claude Code + tmux.

- Multiple Claude Code instances, each in its own terminal window
- File-based communication via Node.js watchers (no fake role-playing)
- Interactive setup: define agent names, roles, and file ownership
- Auto-detects existing configurations — supports Resume / Update / Reset
- Works on any project, any tech stack

**Install:**
```bash
curl -fsSL https://raw.githubusercontent.com/JoWood94/claude-skills/main/multiagent-setup/install.sh | bash
```

**Use:**
```
/multiagent-setup
```

[Full documentation →](multiagent-setup/README.md)

---

## How skills work

Claude Code slash commands are Markdown files stored in `~/.claude/commands/`.
When you type `/skill-name` in any Claude Code session, Claude reads the file and follows the instructions.

To install manually:
```bash
mkdir -p ~/.claude/commands
# copy the .md file of the skill you want into ~/.claude/commands/
```

---

## Install all skills at once

```bash
curl -fsSL https://raw.githubusercontent.com/JoWood94/claude-skills/main/install-all.sh | bash
```

---

## Contributing

Skills are plain Markdown files — no build step, no dependencies.
Open a PR with your skill in its own folder: `your-skill-name/your-skill-name.md`.

## License

MIT
