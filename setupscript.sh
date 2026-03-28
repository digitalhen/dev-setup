#!/bin/bash
# ============================================================
#  Dev Environment Setup for Mac
#  One command to install Claude Code, VS Code, and everything
#  you need to start building with AI.
#
#  Run with:  curl -sL YOUR_URL | bash
#  Or save and run:  bash setup-dev-environment.sh
# ============================================================

set -e

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
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add to PATH for Apple Silicon Macs
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        echo '' >> ~/.zprofile
        echo '# Homebrew' >> ~/.zprofile
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    fi
    done_msg "Homebrew installed"
else
    skip_msg "Homebrew"
fi

# ----------------------------------------------------------
# 2. NODE.JS (required for Claude Code)
# ----------------------------------------------------------
step "Checking for Node.js..."
if ! command -v node &> /dev/null; then
    brew install node
    done_msg "Node.js $(node -v) installed"
else
    NODE_VER=$(node -v)
    skip_msg "Node.js $NODE_VER"
fi

# ----------------------------------------------------------
# 3. VISUAL STUDIO CODE
# ----------------------------------------------------------
step "Checking for VS Code..."
if [ ! -d "/Applications/Visual Studio Code.app" ]; then
    brew install --cask visual-studio-code
    done_msg "VS Code installed"
else
    skip_msg "VS Code"
fi

# Make sure 'code' command is on PATH
if ! command -v code &> /dev/null; then
    VSCODE_BIN="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
    if [ -f "$VSCODE_BIN" ]; then
        sudo ln -sf "$VSCODE_BIN" /usr/local/bin/code 2>/dev/null || true
    fi
    done_msg "'code' command linked"
else
    done_msg "'code .' command is ready"
fi

# ----------------------------------------------------------
# 4. CLAUDE CODE (CLI + VS Code extension)
# ----------------------------------------------------------
step "Installing Claude Code..."
npm install -g @anthropic-ai/claude-code 2>/dev/null
done_msg "Claude Code CLI installed"

# Install the Claude Code VS Code extension
code --install-extension anthropic.claude-code --force 2>/dev/null && \
    done_msg "Claude Code VS Code extension installed" || true

# ----------------------------------------------------------
# 5. CREATE CODE FOLDER
# ----------------------------------------------------------
step "Creating ~/Documents/Code folder..."
mkdir -p "$HOME/Documents/Code"
done_msg "~/Documents/Code is ready"

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
)

for ext in "${EXTENSIONS[@]}"; do
    code --install-extension "$ext" --force 2>/dev/null && \
        done_msg "$ext" || true
done

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
with open('$VSCODE_SETTINGS', 'w') as f:
    json.dump(settings, f, indent=2)
" 2>/dev/null
else
    cat > "$VSCODE_SETTINGS" << 'VSSETTINGS'
{
  "workbench.panel.defaultLocation": "bottom",
  "terminal.integrated.defaultProfile.osx": "zsh",
  "workbench.iconTheme": "material-icon-theme"
}
VSSETTINGS
fi

done_msg "VS Code terminal panel set to bottom"

# ----------------------------------------------------------
# 11. OPEN VS CODE & LAUNCH CLAUDE CODE IN ITS TERMINAL
# ----------------------------------------------------------
step "Launching VS Code with Claude Code..."

# Open VS Code to the Code folder
code "$HOME/Documents/Code"

# Wait for VS Code to finish loading
sleep 4

# Use AppleScript to:
#   1. Bring VS Code to front
#   2. Open the integrated terminal (Ctrl + `)
#   3. Type 'claude' and press Enter
osascript <<'APPLESCRIPT'
tell application "Visual Studio Code" to activate
delay 1.5
tell application "System Events"
    -- Toggle integrated terminal: Ctrl + `
    key code 50 using {control down}
    delay 1
    -- Type 'claude' and hit Enter
    keystroke "claude"
    delay 0.3
    key code 36
end tell
APPLESCRIPT

done_msg "Claude Code launched inside VS Code"

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
echo -e "  ${BOLD}Claude Code${NC}      Running in VS Code's terminal right now"
echo -e "  ${BOLD}Extensions${NC}       Prettier, GitLens, Python, Claude Code, + more"
echo -e "  ${BOLD}~/Documents/Code${NC} Your project folder (open in VS Code)"
echo -e "  ${BOLD}Terminal theme${NC}   Homebrew (green on black)"
echo ""
echo -e "  ${Y}Next time:${NC} Just open VS Code and type ${BOLD}claude${NC} in the terminal"
echo ""
