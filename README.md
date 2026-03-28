# Dev Setup

One command to set up a Mac or Windows machine for development with Claude Code, VS Code, and essential tools.

## Quick Start

### macOS

```bash
curl -sL "https://raw.githubusercontent.com/digitalhen/dev-setup/main/setupscript.sh?$(date +%s)" | bash
```

Or clone and run:

```bash
git clone https://github.com/digitalhen/dev-setup.git
bash dev-setup/setupscript.sh
```

### Windows

```powershell
irm "https://raw.githubusercontent.com/digitalhen/dev-setup/main/setup.ps1?$(Get-Date -UFormat %s)" | iex
```

Or clone and run:

```powershell
git clone https://github.com/digitalhen/dev-setup.git
.\dev-setup\setup.ps1
```

> If blocked by execution policy, run first: `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`

## What It Installs

| Tool | Purpose | Mac | Windows |
|------|---------|-----|---------|
| **Homebrew** | Package manager | Yes | — |
| **winget** | Package manager (built-in) | — | Yes |
| **Node.js** | Required runtime for Claude Code | Yes | Yes |
| **VS Code** | Code editor | Yes | Yes |
| **Claude Code** | AI coding assistant (CLI + VS Code extension) | Yes | Yes |

## What It Configures

- **VS Code extensions**: Prettier, GitLens, Python, ESLint, Tailwind CSS, and more
- **VS Code settings**: Terminal panel at bottom, default shell (zsh on Mac, PowerShell on Windows), Material Icon Theme
- **Claude Code permissions**: Common read-only tools auto-allowed
- **Terminal theme**: Homebrew (green on black) — Mac only
- **Project folder**: `~/Documents/Code` created with a `hello-world` starter project
- **Auto-launch**: Claude Code starts automatically when the hello-world project opens in VS Code

## Requirements

### macOS
- macOS (Apple Silicon or Intel)
- Admin password (for Homebrew installation)

### Windows
- Windows 10/11 with [winget](https://aka.ms/getwinget) (pre-installed on Windows 11)
- PowerShell 5.1+ (pre-installed)

### Both
- An [Anthropic API key](https://console.anthropic.com/) or Claude subscription (Claude Code will prompt you on first run)

## First Thing to Try

Once Claude Code starts in the VS Code terminal, type:

> **Build me a hello world webpage with HTML, CSS, and JavaScript**

## Re-running

Both scripts are idempotent — they skip anything already installed so you can safely run them again.
