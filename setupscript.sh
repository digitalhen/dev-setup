#!/bin/bash
# ============================================================
#  Dev Environment Setup for Mac
#  One command to install Claude Code, VS Code, and everything
#  you need to start building with AI.
#
#  Run with:
#    curl -sL "https://raw.githubusercontent.com/digitalhen/dev-setup/main/setupscript.sh?$(date +%s)" | bash
#
#  Or clone and run:
#    git clone https://github.com/digitalhen/dev-setup.git && bash dev-setup/setupscript.sh
# ============================================================

set -u


# --- Pretty output ---
G='\033[0;32m'  # Green
B='\033[1;34m'  # Blue
Y='\033[1;33m'  # Yellow
R='\033[0;31m'  # Red
BOLD='\033[1m'
NC='\033[0m'    # No color

step() { echo -e "\n${B}▸ $1${NC}"; }
done_msg() { echo -e "  ${G}✓ $1${NC}"; }
skip_msg() { echo -e "  ${Y}⊘ $1 (already installed)${NC}"; }
warn_msg() { echo -e "  ${Y}⚠ $1${NC}"; }
fail_msg() { echo -e "  ${R}✗ $1${NC}"; }
fatal() { echo -e "\n${R}${BOLD}  ERROR: $1${NC}"; echo -e "  ${R}$2${NC}"; exit 1; }

# --- Require macOS ---
if [[ "$(uname)" != "Darwin" ]]; then
    echo -e "${R}This script is designed for macOS only.${NC}"
    exit 1
fi

echo ""
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}  🚀  Dev Environment Setup                           ${NC}"
echo -e "${BOLD}  Claude Code + VS Code + everything you need         ${NC}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# ----------------------------------------------------------
# 1. HOMEBREW
# ----------------------------------------------------------
step "Checking for Homebrew..."
if ! command -v brew &> /dev/null; then
    echo -e "  Installing Homebrew (you may be asked for your password)..."
    # Pre-cache sudo credentials so Homebrew's installer doesn't need to prompt.
    # We do this ourselves because NONINTERACTIVE=1 makes Homebrew skip its own
    # sudo prompt, and < /dev/tty gives us access to the real terminal for the
    # password (since stdin is a pipe when run via curl | bash).
    sudo -v < /dev/tty
    # NONINTERACTIVE=1 skips Homebrew's "press ENTER to continue" confirmation.
    # sudo is already cached, so it won't need to prompt again.
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add to PATH for Apple Silicon Macs (avoid duplicate entries)
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        if ! grep -q 'opt/homebrew/bin/brew shellenv' ~/.zprofile 2>/dev/null; then
            echo '' >> ~/.zprofile
            echo '# Homebrew' >> ~/.zprofile
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        fi
    fi
    # Verify it actually installed
    if command -v brew &> /dev/null; then
        done_msg "Homebrew installed"
    else
        fatal "Homebrew installation failed." \
              "Try running this script again, or install Homebrew manually: https://brew.sh"
    fi
else
    skip_msg "Homebrew"
fi

# ----------------------------------------------------------
# 2. NODE.JS (required for Claude Code)
# ----------------------------------------------------------
step "Checking for Node.js..."
if ! command -v node &> /dev/null; then
    brew install node </dev/null
    if command -v node &> /dev/null; then
        done_msg "Node.js $(node -v) installed"
    else
        fatal "Node.js installation failed." \
              "Try: brew install node"
    fi
else
    NODE_VER=$(node -v)
    skip_msg "Node.js $NODE_VER"
fi

# ----------------------------------------------------------
# 3. VISUAL STUDIO CODE
# ----------------------------------------------------------
step "Checking for VS Code..."
if [ ! -d "/Applications/Visual Studio Code.app" ]; then
    brew install --cask visual-studio-code </dev/null
    if [ -d "/Applications/Visual Studio Code.app" ]; then
        done_msg "VS Code installed"
    else
        fatal "VS Code installation failed." \
              "Try: brew install --cask visual-studio-code"
    fi
else
    skip_msg "VS Code"
fi

# Make sure 'code' command is on PATH
if ! command -v code &> /dev/null; then
    VSCODE_BIN="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
    if [ -f "$VSCODE_BIN" ]; then
        # Try user-local bin first, fall back to sudo
        mkdir -p "$HOME/.local/bin"
        ln -sf "$VSCODE_BIN" "$HOME/.local/bin/code" 2>/dev/null || \
            sudo ln -sf "$VSCODE_BIN" /usr/local/bin/code 2>/dev/null || true
        export PATH="$HOME/.local/bin:$PATH"
        done_msg "'code' command linked"
    else
        warn_msg "'code' command not found — open VS Code and run 'Shell Command: Install code' from the command palette"
    fi
else
    done_msg "'code' command is ready"
fi

# ----------------------------------------------------------
# 4. CLAUDE CODE (CLI + VS Code extension)
# ----------------------------------------------------------
step "Installing Claude Code..."
if npm install -g @anthropic-ai/claude-code </dev/null 2>/dev/null; then
    done_msg "Claude Code CLI installed"
else
    fatal "Claude Code installation failed." \
          "Try: npm install -g @anthropic-ai/claude-code"
fi

# Install the Claude Code VS Code extension
if command -v code &> /dev/null; then
    if code --install-extension anthropic.claude-code --force 2>/dev/null; then
        done_msg "Claude Code VS Code extension installed"
    else
        warn_msg "Could not install Claude Code VS Code extension — install it manually from the Extensions panel"
    fi
fi

# ----------------------------------------------------------
# 5. CREATE CODE FOLDER & HELLO WORLD PROJECT
# ----------------------------------------------------------
step "Creating ~/Documents/Code folder..."
mkdir -p "$HOME/Documents/Code"
done_msg "~/Documents/Code is ready"

step "Creating hello-world project..."
PROJECT_DIR="$HOME/Documents/Code/hello-world"
mkdir -p "$PROJECT_DIR"
done_msg "~/Documents/Code/hello-world is ready"

# ----------------------------------------------------------
# 6. VS CODE EXTENSIONS
# ----------------------------------------------------------
step "Installing useful VS Code extensions..."

EXTENSIONS=(
    "esbenp.prettier-vscode"         # Auto-format code
    "PKief.material-icon-theme"      # Nice file icons
    "eamodio.gitlens"                # Git history & blame
    "ms-python.python"               # Python support
    "dbaeumer.vscode-eslint"         # JavaScript linting
    "bradlc.vscode-tailwindcss"      # Tailwind CSS
    "formulahendry.auto-rename-tag"  # Auto rename HTML tags
    "streetsidesoftware.code-spell-checker"  # Spell check
    "ritwickdey.LiveServer"                  # Local dev server for HTML/CSS/JS
)

if command -v code &> /dev/null; then
    for ext in "${EXTENSIONS[@]}"; do
        if code --install-extension "$ext" --force 2>/dev/null; then
            done_msg "$ext"
        else
            warn_msg "Failed to install $ext"
        fi
    done
else
    warn_msg "Skipping extensions — 'code' command not available"
fi

# ----------------------------------------------------------
# 7. CONFIGURE CLAUDE CODE - Allow non-destructive commands
# ----------------------------------------------------------
step "Configuring Claude Code permissions..."
mkdir -p "$HOME/.claude"

cat > "$HOME/.claude/settings.json" << 'SETTINGS'
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
SETTINGS

done_msg "Non-destructive tools auto-allowed"

# ----------------------------------------------------------
# 8. SET TERMINAL TO HOMEBREW THEME
# ----------------------------------------------------------
step "Setting Terminal to Homebrew theme..."
defaults write com.apple.Terminal "Default Window Settings" -string "Homebrew"
defaults write com.apple.Terminal "Startup Window Settings" -string "Homebrew"
done_msg "Terminal set to Homebrew (green on black)"

# ----------------------------------------------------------
# 9. ADD VS CODE TO THE DOCK
# ----------------------------------------------------------
step "Adding VS Code to the Dock..."

if ! defaults read com.apple.dock persistent-apps 2>/dev/null | grep -q "Visual Studio Code"; then
    defaults write com.apple.dock persistent-apps -array-add \
        "<dict>
            <key>tile-data</key>
            <dict>
                <key>file-data</key>
                <dict>
                    <key>_CFURLString</key>
                    <string>/Applications/Visual Studio Code.app</string>
                    <key>_CFURLStringType</key>
                    <integer>0</integer>
                </dict>
            </dict>
        </dict>"
    killall Dock 2>/dev/null || true
    done_msg "VS Code added to Dock"
else
    skip_msg "VS Code already in Dock"
fi

# ----------------------------------------------------------
# 10. CONFIGURE VS CODE (terminal at bottom, theme, etc.)
# ----------------------------------------------------------
step "Configuring VS Code settings..."
VSCODE_SETTINGS_DIR="$HOME/Library/Application Support/Code/User"
mkdir -p "$VSCODE_SETTINGS_DIR"

VSCODE_SETTINGS="$VSCODE_SETTINGS_DIR/settings.json"

if [ -f "$VSCODE_SETTINGS" ]; then
    # Merge our keys into existing settings without overwriting
    python3 -c "
import json
with open('$VSCODE_SETTINGS', 'r') as f:
    try:
        settings = json.load(f)
    except:
        settings = {}
settings['workbench.panel.defaultLocation'] = 'bottom'
settings['terminal.integrated.defaultProfile.osx'] = 'zsh'
settings['workbench.iconTheme'] = 'material-icon-theme'
settings['remote.autoForwardPorts'] = False
settings['remote.autoForwardPortsSource'] = 'output'
with open('$VSCODE_SETTINGS', 'w') as f:
    json.dump(settings, f, indent=2)
" 2>/dev/null
else
    cat > "$VSCODE_SETTINGS" << 'VSSETTINGS'
{
  "workbench.panel.defaultLocation": "bottom",
  "terminal.integrated.defaultProfile.osx": "zsh",
  "workbench.iconTheme": "material-icon-theme",
  "remote.autoForwardPorts": false,
  "remote.autoForwardPortsSource": "output"
}
VSSETTINGS
fi

done_msg "VS Code terminal panel set to bottom"

# ----------------------------------------------------------
# 11. OPEN VS CODE WITH CLAUDE CODE IN THE TERMINAL
# ----------------------------------------------------------
step "Launching VS Code with Claude Code..."

# Set up a VS Code task in the hello-world project that launches
# Claude Code automatically when the folder is opened
WORKSPACE_VSCODE="$PROJECT_DIR/.vscode"
mkdir -p "$WORKSPACE_VSCODE"

TASKS_FILE="$WORKSPACE_VSCODE/tasks.json"
if [ ! -f "$TASKS_FILE" ]; then
    cat > "$TASKS_FILE" << 'TASKS'
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
TASKS
    done_msg "VS Code task configured to launch Claude on folder open"
else
    skip_msg "tasks.json already exists"
fi

# Open VS Code to the hello-world project in a new window
if command -v code &> /dev/null; then
    code --new-window "$PROJECT_DIR" </dev/null &>/dev/null || code "$PROJECT_DIR" </dev/null &>/dev/null || true
    done_msg "VS Code opened ~/Documents/Code/hello-world"
else
    open -a "Visual Studio Code" "$PROJECT_DIR" </dev/null &>/dev/null || true
    done_msg "VS Code opened ~/Documents/Code/hello-world"
fi
echo -e "  ${Y}Note:${NC} VS Code may ask to allow automatic tasks. Click ${BOLD}\"Allow and Run\"${NC}."

# ----------------------------------------------------------
# DONE
# ----------------------------------------------------------
echo ""
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${G}${BOLD}  ✅  All done! Here's what was set up:${NC}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${BOLD}Homebrew${NC}         Package manager for Mac"
echo -e "  ${BOLD}Node.js${NC}          Required for Claude Code"
echo -e "  ${BOLD}VS Code${NC}          Code editor (in your Dock, panel at bottom)"
echo -e "  ${BOLD}Claude Code${NC}      Auto-launches in the hello-world project"
echo -e "  ${BOLD}Extensions${NC}       Prettier, GitLens, Python, Claude Code, + more"
echo -e "  ${BOLD}~/Documents/Code${NC} Your projects folder"
echo -e "  ${BOLD}hello-world${NC}      Starter project (open in VS Code now)"
echo -e "  ${BOLD}Terminal theme${NC}   Homebrew (green on black)"
echo ""
echo -e "  ${Y}Try this now:${NC} When Claude starts, type:"
echo ""
echo -e "    ${BOLD}Build me a hello world webpage with HTML, CSS, and JavaScript${NC}"
echo ""
echo -e "  ${Y}Next time:${NC} Just open VS Code and type ${BOLD}claude${NC} in the terminal"
echo ""
