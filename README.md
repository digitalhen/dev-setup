# Dev Setup for Mac

One command to set up a Mac for development with Claude Code, VS Code, and essential tools.

## Quick Start

```bash
curl -sL "https://raw.githubusercontent.com/digitalhen/dev-setup/main/setupscript.sh?$(date +%s)" | bash
```

Or clone and run:

```bash
git clone https://github.com/digitalhen/dev-setup.git
bash dev-setup/setupscript.sh
```

## What It Installs

| Tool | Purpose |
|------|---------|
| **Homebrew** | Package manager for macOS |
| **Node.js** | Required runtime for Claude Code |
| **VS Code** | Code editor, added to Dock |
| **Claude Code** | AI coding assistant (CLI + VS Code extension) |

## What It Configures

- **VS Code extensions**: Prettier, GitLens, Python, ESLint, Tailwind CSS, and more
- **VS Code settings**: Terminal panel at bottom, zsh as default shell, Material Icon Theme
- **Claude Code permissions**: Common read-only tools auto-allowed
- **Terminal theme**: Homebrew (green on black)
- **Project folder**: `~/Documents/Code` created with a `hello-world` starter project
- **Auto-launch**: Claude Code starts automatically when the hello-world project opens in VS Code

## Requirements

- macOS (Apple Silicon or Intel)
- Admin password (for Homebrew installation)
- An [Anthropic API key](https://console.anthropic.com/) or Claude subscription (Claude Code will prompt you on first run)

## Re-running

The script is idempotent — it skips anything already installed so you can safely run it again.
