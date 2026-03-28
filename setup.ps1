# ============================================================
#  Dev Environment Setup for Windows
#  One command to install Claude Code, VS Code, and everything
#  you need to start building with AI.
#
#  Run with:
#    irm "https://raw.githubusercontent.com/digitalhen/dev-setup/main/setup.ps1?$(Get-Date -UFormat %s)" | iex
#
#  Or clone and run:
#    git clone https://github.com/digitalhen/dev-setup.git; .\dev-setup\setup.ps1
#
#  If blocked by execution policy, run first:
#    Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
# ============================================================

#Requires -Version 5.1

$ErrorActionPreference = 'Continue'

# --- Pretty output ---
function Step($msg)  { Write-Host "`n$([char]0x25B8) $msg" -ForegroundColor Blue }
function Done($msg)  { Write-Host "  $([char]0x2713) $msg" -ForegroundColor Green }
function Skip($msg)  { Write-Host "  $([char]0x2298) $msg (already installed)" -ForegroundColor Yellow }
function Warn($msg)  { Write-Host "  $([char]0x26A0) $msg" -ForegroundColor Red }

function Refresh-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("Path", "User")
}

# --- Require Windows ---
if ($env:OS -ne "Windows_NT") {
    Write-Host "This script is designed for Windows only." -ForegroundColor Red
    exit 1
}

Write-Host ""
$rule = [string]::new([char]0x2501, 53)
Write-Host $rule -ForegroundColor White
Write-Host "  Dev Environment Setup" -ForegroundColor White
Write-Host "  Claude Code + VS Code + everything you need" -ForegroundColor White
Write-Host $rule -ForegroundColor White
Write-Host ""

# ----------------------------------------------------------
# 1. WINGET (Windows Package Manager)
# ----------------------------------------------------------
Step "Checking for winget..."
if (Get-Command winget -ErrorAction SilentlyContinue) {
    Done "winget is available"
} else {
    Warn "winget not found. Install 'App Installer' from the Microsoft Store, then re-run this script."
    exit 1
}

# ----------------------------------------------------------
# 2. NODE.JS (required for Claude Code)
# ----------------------------------------------------------
Step "Checking for Node.js..."
if (Get-Command node -ErrorAction SilentlyContinue) {
    $nodeVer = node -v
    Skip "Node.js $nodeVer"
} else {
    Write-Host "  Installing Node.js..." -ForegroundColor Gray
    winget install --id OpenJS.NodeJS.LTS -e --accept-source-agreements --accept-package-agreements | Out-Null
    Refresh-Path
    if (Get-Command node -ErrorAction SilentlyContinue) {
        Done "Node.js $(node -v) installed"
    } else {
        Warn "Node.js installed but not on PATH yet. You may need to restart your terminal after this script finishes."
    }
}

# ----------------------------------------------------------
# 3. VISUAL STUDIO CODE
# ----------------------------------------------------------
Step "Checking for VS Code..."
if (Get-Command code -ErrorAction SilentlyContinue) {
    Skip "VS Code"
} else {
    Write-Host "  Installing VS Code..." -ForegroundColor Gray
    winget install --id Microsoft.VisualStudioCode -e --accept-source-agreements --accept-package-agreements | Out-Null
    Refresh-Path
    if (Get-Command code -ErrorAction SilentlyContinue) {
        Done "VS Code installed"
    } else {
        Warn "VS Code installed but 'code' not on PATH yet. You may need to restart your terminal."
    }
}

# ----------------------------------------------------------
# 4. CLAUDE CODE (CLI + VS Code extension)
# ----------------------------------------------------------
Step "Installing Claude Code..."
# Use npm.cmd to avoid execution policy blocking npm.ps1
$npmCmd = Get-Command npm.cmd -ErrorAction SilentlyContinue
if ($npmCmd) {
    & npm.cmd install -g @anthropic-ai/claude-code 2>&1 | Out-Null
    Refresh-Path
    if (Get-Command claude -ErrorAction SilentlyContinue) {
        Done "Claude Code CLI installed"
    } else {
        Warn "npm install ran but 'claude' not found on PATH. Try restarting your terminal."
    }
} else {
    Warn "npm not found. Make sure Node.js is installed and on your PATH."
}

if (Get-Command code -ErrorAction SilentlyContinue) {
    code --install-extension anthropic.claude-code --force 2>$null | Out-Null
    Done "Claude Code VS Code extension installed"
}

# ----------------------------------------------------------
# 5. CREATE CODE FOLDER & HELLO WORLD PROJECT
# ----------------------------------------------------------
Step "Creating ~/Documents/Code folder..."
New-Item -ItemType Directory -Force -Path "$HOME\Documents\Code" | Out-Null
Done "~/Documents/Code is ready"

Step "Creating hello-world project..."
$ProjectDir = "$HOME\Documents\Code\hello-world"
New-Item -ItemType Directory -Force -Path $ProjectDir | Out-Null
Done "~/Documents/Code/hello-world is ready"

# ----------------------------------------------------------
# 6. VS CODE EXTENSIONS
# ----------------------------------------------------------
Step "Installing useful VS Code extensions..."

if (Get-Command code -ErrorAction SilentlyContinue) {
    $extensions = @(
        "esbenp.prettier-vscode"
        "PKief.material-icon-theme"
        "eamodio.gitlens"
        "ms-python.python"
        "dbaeumer.vscode-eslint"
        "bradlc.vscode-tailwindcss"
        "formulahendry.auto-rename-tag"
        "streetsidesoftware.code-spell-checker"
        "ritwickdey.LiveServer"
    )

    foreach ($ext in $extensions) {
        try {
            code --install-extension $ext --force 2>$null | Out-Null
            Done $ext
        } catch {
            Warn "Failed to install $ext"
        }
    }
} else {
    Warn "VS Code 'code' command not found, skipping extensions"
}

# ----------------------------------------------------------
# 7. CONFIGURE CLAUDE CODE - Allow non-destructive commands
# ----------------------------------------------------------
Step "Configuring Claude Code permissions..."
New-Item -ItemType Directory -Force -Path "$HOME\.claude" | Out-Null

$claudeSettings = @'
{
  "permissions": {
    "allow": [
      "Read",
      "Glob",
      "Grep",
      "LS",
      "WebFetch",
      "WebSearch",
      "Task",
      "Bash(cat *)",
      "Bash(ls *)",
      "Bash(head *)",
      "Bash(tail *)",
      "Bash(wc *)",
      "Bash(find *)",
      "Bash(which *)",
      "Bash(echo *)",
      "Bash(pwd)",
      "Bash(date)",
      "Bash(git status)",
      "Bash(git log *)",
      "Bash(git diff *)",
      "Bash(git branch *)",
      "Bash(node --version)",
      "Bash(npm list *)",
      "Bash(python3 --version)",
      "Bash(code *)"
    ]
  }
}
'@

Set-Content -Path "$HOME\.claude\settings.json" -Value $claudeSettings -Encoding UTF8
Done "Non-destructive tools auto-allowed"

# ----------------------------------------------------------
# 8. CONFIGURE VS CODE SETTINGS
# ----------------------------------------------------------
Step "Configuring VS Code settings..."
$vsCodeSettingsDir = "$env:APPDATA\Code\User"
New-Item -ItemType Directory -Force -Path $vsCodeSettingsDir | Out-Null

$vsCodeSettingsFile = "$vsCodeSettingsDir\settings.json"

$newSettings = @{
    "workbench.panel.defaultLocation"            = "bottom"
    "terminal.integrated.defaultProfile.windows"  = "PowerShell"
    "workbench.iconTheme"                         = "material-icon-theme"
    "remote.autoForwardPorts"                     = $false
    "remote.autoForwardPortsSource"               = "output"
}

if (Test-Path $vsCodeSettingsFile) {
    try {
        # Strip single-line comments (VS Code uses JSONC)
        $raw = Get-Content $vsCodeSettingsFile -Raw
        $cleaned = ($raw -replace '//.*$', '' -replace '/\*[\s\S]*?\*/', '')
        $settings = $cleaned | ConvertFrom-Json

        foreach ($key in $newSettings.Keys) {
            $settings | Add-Member -NotePropertyName $key -NotePropertyValue $newSettings[$key] -Force
        }

        $settings | ConvertTo-Json -Depth 10 | Set-Content $vsCodeSettingsFile -Encoding UTF8
    } catch {
        # If parsing fails, write fresh settings
        $newSettings | ConvertTo-Json -Depth 10 | Set-Content $vsCodeSettingsFile -Encoding UTF8
    }
} else {
    $newSettings | ConvertTo-Json -Depth 10 | Set-Content $vsCodeSettingsFile -Encoding UTF8
}

Done "VS Code settings configured"

# ----------------------------------------------------------
# 9. TASKS.JSON - Auto-launch Claude Code in hello-world
# ----------------------------------------------------------
Step "Configuring auto-launch task..."
$vscodeDir = "$ProjectDir\.vscode"
New-Item -ItemType Directory -Force -Path $vscodeDir | Out-Null

$tasksFile = "$vscodeDir\tasks.json"
if (-not (Test-Path $tasksFile)) {
    $tasksJson = @'
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Start Claude Code",
      "type": "shell",
      "command": "claude",
      "isBackground": true,
      "presentation": {
        "reveal": "always",
        "panel": "dedicated",
        "focus": true
      },
      "runOptions": {
        "runOn": "folderOpen"
      },
      "problemMatcher": []
    }
  ]
}
'@
    Set-Content -Path $tasksFile -Value $tasksJson -Encoding UTF8
    Done "VS Code task configured to launch Claude on folder open"
} else {
    Skip "tasks.json already exists"
}

# ----------------------------------------------------------
# 10. OPEN VS CODE
# ----------------------------------------------------------
Step "Launching VS Code with Claude Code..."
if (Get-Command code -ErrorAction SilentlyContinue) {
    code --new-window $ProjectDir 2>$null
    Done "VS Code opened ~/Documents/Code/hello-world"
} else {
    Warn "Could not launch VS Code. Open it manually and open the folder: $ProjectDir"
}
Write-Host "  Note: VS Code may ask to allow automatic tasks. Click " -ForegroundColor Yellow -NoNewline
Write-Host '"Allow and Run"' -ForegroundColor White -NoNewline
Write-Host "." -ForegroundColor Yellow

# ----------------------------------------------------------
# DONE
# ----------------------------------------------------------
Write-Host ""
Write-Host $rule -ForegroundColor White
Write-Host "  All done! Here's what was set up:" -ForegroundColor Green
Write-Host $rule -ForegroundColor White
Write-Host ""
Write-Host "  Node.js          " -ForegroundColor White -NoNewline; Write-Host "Required for Claude Code"
Write-Host "  VS Code          " -ForegroundColor White -NoNewline; Write-Host "Code editor (panel at bottom)"
Write-Host "  Claude Code      " -ForegroundColor White -NoNewline; Write-Host "Auto-launches in the hello-world project"
Write-Host "  Extensions       " -ForegroundColor White -NoNewline; Write-Host "Prettier, GitLens, Python, Claude Code, + more"
Write-Host "  ~/Documents/Code " -ForegroundColor White -NoNewline; Write-Host "Your projects folder"
Write-Host "  hello-world      " -ForegroundColor White -NoNewline; Write-Host "Starter project (open in VS Code now)"
Write-Host ""
Write-Host "  Try this now:" -ForegroundColor Yellow -NoNewline; Write-Host " When Claude starts, type:"
Write-Host ""
Write-Host "    Build me a hello world webpage with HTML, CSS, and JavaScript" -ForegroundColor White
Write-Host ""
Write-Host "  Next time:" -ForegroundColor Yellow -NoNewline; Write-Host " Just open VS Code and type " -NoNewline; Write-Host "claude" -ForegroundColor White -NoNewline; Write-Host " in the terminal"
Write-Host ""
