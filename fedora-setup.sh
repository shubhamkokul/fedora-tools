#!/bin/bash
# fedora-setup.sh — Full post-install setup for Fedora Workstation
#
# Usage:
#   ./fedora-setup.sh              # run everything
#   ./fedora-setup.sh phase1       # run a specific phase
#
# Set env vars before running to override defaults:
#   GIT_NAME="Your Name" GIT_EMAIL="you@email.com" ./fedora-setup.sh

set -euo pipefail

# ─── CONFIG ───────────────────────────────────────────────────────────────────
GIT_NAME="${GIT_NAME:-}"
GIT_EMAIL="${GIT_EMAIL:-}"
GITHUB_USERNAME="${GITHUB_USERNAME:-}"
FEDORA_TOOLS_DIR="${FEDORA_TOOLS_DIR:-$HOME/Dev/fedora-tools}"
# ANTHROPIC_API_KEY — set this in your environment before running, or add manually after
# ──────────────────────────────────────────────────────────────────────────────

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
log()     { echo -e "${GREEN}[+]${NC} $*"; }
warn()    { echo -e "${YELLOW}[!]${NC} $*"; }
info()    { echo -e "${BLUE}[i]${NC} $*"; }
section() { echo -e "\n${BLUE}━━━ $* ━━━${NC}"; }

append_if_missing() {
    local line="$1" file="$2"
    grep -qF "$line" "$file" 2>/dev/null || echo "$line" >> "$file"
}

# ─── PHASE 1 — System Base ───────────────────────────────────────────────────
phase1() {
    section "Phase 1 — System Base"

    log "Updating system..."
    sudo dnf update -y

    log "Enabling RPM Fusion..."
    sudo dnf install -y \
        "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
        "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm" || true

    log "Enabling Flathub..."
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

    log "Installing media codecs..."
    sudo dnf install -y \
        gstreamer1-plugins-bad-free gstreamer1-plugins-good gstreamer1-plugins-base \
        gstreamer1-plugin-openh264 gstreamer1-libav ffmpeg lame || true
    sudo dnf group upgrade --with-optional Multimedia -y || true

    log "Installing GNOME tweaks and extension tools..."
    sudo dnf install -y gnome-tweaks gnome-extensions-app dconf-editor
    flatpak install -y flathub com.mattjakeman.ExtensionManager || true

    warn "Reboot recommended before continuing. Run phase2 after reboot."
}

# ─── PHASE 2 — Desktop UI & GNOME ────────────────────────────────────────────
phase2() {
    section "Phase 2 — Desktop UI & GNOME"

    log "Installing Tiling Shell extension..."
    pip install gnome-extensions-cli --break-system-packages -q || true
    ~/.local/bin/gext install tilingshell@ferrarodomenico.com || true
    ~/.local/bin/gext enable tilingshell@ferrarodomenico.com || true

    local SCHEMA_DIR="$HOME/.local/share/gnome-shell/extensions/tilingshell@ferrarodomenico.com/schemas"
    if [ -d "$SCHEMA_DIR" ]; then
        log "Applying Tiling Shell layouts..."
        gsettings --schemadir "$SCHEMA_DIR" \
            set org.gnome.shell.extensions.tilingshell layouts-json \
            '[{"id":"Two Portrait","tiles":[{"x":0,"y":0,"width":0.5,"height":0.5,"groups":[1,2]},{"x":0,"y":0.5,"width":0.5,"height":0.5,"groups":[1,3]},{"x":0.5,"y":0,"width":0.5,"height":0.5,"groups":[2,4]},{"x":0.5,"y":0.5,"width":0.5,"height":0.5,"groups":[3,4]}]},{"id":"Half & Half","tiles":[{"x":0,"y":0,"width":0.5,"height":1,"groups":[1]},{"x":0.5,"y":0,"width":0.5,"height":1,"groups":[1]}]},{"id":"Top & Bottom","tiles":[{"x":0,"y":0,"width":1,"height":0.5,"groups":[1]},{"x":0,"y":0.5,"width":1,"height":0.5,"groups":[1]}]},{"id":"Main + Side","tiles":[{"x":0,"y":0,"width":0.67,"height":1,"groups":[1]},{"x":0.67,"y":0,"width":0.33,"height":1,"groups":[1]}]},{"id":"3 Columns","tiles":[{"x":0,"y":0,"width":0.33,"height":1,"groups":[1]},{"x":0.33,"y":0,"width":0.34,"height":1,"groups":[1,2]},{"x":0.67,"y":0,"width":0.33,"height":1,"groups":[2]}]}]'
    fi

    log "Configuring Dash to Dock (autohide, intellihide)..."
    gsettings set org.gnome.shell.extensions.dash-to-dock autohide true
    gsettings set org.gnome.shell.extensions.dash-to-dock autohide-in-fullscreen true
    gsettings set org.gnome.shell.extensions.dash-to-dock intellihide true
    gsettings set org.gnome.shell.extensions.dash-to-dock intellihide-mode 'FOCUS_APPLICATION_WINDOWS'
    gsettings set org.gnome.shell.extensions.dash-to-dock pressure-threshold 100.0
    gsettings set org.gnome.shell.extensions.dash-to-dock require-pressure-to-show false
    gsettings set org.gnome.shell.extensions.dash-to-dock show-delay 0.2

    log "Installing icon and cursor themes..."
    sudo dnf install -y papirus-icon-theme bibata-cursor-themes || true

    warn "Log out and back in to activate Tiling Shell on Wayland."
}

# ─── PHASE 3 — Terminal & Shell ──────────────────────────────────────────────
phase3() {
    section "Phase 3 — Terminal & Shell"

    log "Installing zsh..."
    sudo dnf install -y zsh util-linux-user
    if [ "$SHELL" != "$(which zsh)" ]; then
        chsh -s "$(which zsh)"
        warn "Shell changed to zsh — takes effect on next login"
    fi

    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        log "Installing Oh My Zsh..."
        RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    else
        info "Oh My Zsh already installed, skipping"
    fi

    log "Installing terminal tools..."
    sudo dnf install -y \
        tmux htop btop fzf bat eza ripgrep fd-find jq \
        wget curl unzip zip p7zip tree neofetch

    log "Installing JetBrains Mono font..."
    sudo dnf install -y jetbrains-mono-fonts

    log "Installing WezTerm..."
    flatpak install -y flathub org.wezfurlong.wezterm || true

    log "Cloning fedora-tools and applying WezTerm config..."
    mkdir -p ~/Dev
    if [ ! -d "$FEDORA_TOOLS_DIR" ]; then
        git clone "https://github.com/${GITHUB_USERNAME}/fedora-tools.git" "$FEDORA_TOOLS_DIR"
    else
        info "fedora-tools already cloned, pulling latest..."
        git -C "$FEDORA_TOOLS_DIR" pull
    fi
    mkdir -p ~/.config/wezterm
    cp "$FEDORA_TOOLS_DIR/wezterm.lua" ~/.config/wezterm/wezterm.lua
    log "WezTerm config applied"
}

# ─── PHASE 4 — Dev Environment ───────────────────────────────────────────────
phase4() {
    section "Phase 4 — Dev Environment"

    log "Installing git..."
    sudo dnf install -y git git-lfs
    git config --global user.name "$GIT_NAME"
    git config --global user.email "$GIT_EMAIL"
    git config --global core.editor "code --wait"
    git config --global pull.rebase false

    log "Installing GitHub CLI..."
    sudo dnf install -y gh
    warn "Run 'gh auth login' manually to authenticate GitHub CLI"

    warn "SSH key: run 'ssh-keygen -t ed25519 -C ${GIT_EMAIL}' then add public key to GitHub"

    log "Installing Java 21..."
    sudo dnf install -y java-21-openjdk java-21-openjdk-devel
    append_if_missing 'export JAVA_HOME=/usr/lib/jvm/java-21-openjdk' ~/.zshrc
    append_if_missing 'export PATH=$JAVA_HOME/bin:$PATH' ~/.zshrc

    log "Installing Maven..."
    sudo dnf install -y maven

    log "Installing Go..."
    sudo dnf install -y golang
    append_if_missing 'export GOPATH=$HOME/go' ~/.zshrc
    append_if_missing 'export PATH=$GOPATH/bin:$PATH' ~/.zshrc

    log "Installing nvm + Node.js 22..."
    if [ ! -d "$HOME/.nvm" ]; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    fi
    export NVM_DIR="$HOME/.nvm"
    # shellcheck source=/dev/null
    [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
    nvm install 22
    nvm alias default 22

    log "Installing Python 3..."
    sudo dnf install -y python3-pip python3-virtualenv
    pip3 install --upgrade pip --quiet

    log "Installing Docker..."
    sudo dnf install -y docker docker-compose
    sudo systemctl enable --now docker
    sudo usermod -aG docker "$USER" || true
    warn "Log out and back in for Docker group to take effect (or run 'newgrp docker')"

    log "Installing kubectl..."
    sudo dnf install -y kubectl || true

    log "Installing PowerShell Core..."
    sudo dnf install -y powershell || true

    log "Installing PostgreSQL..."
    sudo dnf install -y postgresql postgresql-server
    warn "PostgreSQL installed but NOT initialized. Run 'sudo postgresql-setup --initdb' when needed."

    log "Installing pgAdmin4..."
    flatpak install -y flathub org.pgadmin.pgadmin4 || true

    log "Adding Grafana repo and installing..."
    sudo tee /etc/yum.repos.d/grafana.repo > /dev/null <<'EOF'
[grafana]
name=grafana
baseurl=https://rpm.grafana.com
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://rpm.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOF
    sudo dnf install -y grafana || true
    warn "Grafana installed but NOT started. Run 'sudo systemctl start grafana-server' when needed."

    log "Adding MongoDB repo and installing..."
    sudo tee /etc/yum.repos.d/mongodb-org-8.0.repo > /dev/null <<'EOF'
[mongodb-org-8.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/9/mongodb-org/8.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://pgp.mongodb.com/server-8.0.asc
EOF
    sudo dnf install -y mongodb-org || true
    sudo systemctl disable mongod 2>/dev/null || true
    warn "MongoDB installed but NOT started. Run 'sudo systemctl start mongod' when needed."
}

# ─── PHASE 5 — IDEs & Editors ────────────────────────────────────────────────
phase5() {
    section "Phase 5 — IDEs & Editors"

    log "Installing VS Code..."
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo tee /etc/yum.repos.d/vscode.repo > /dev/null <<'EOF'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
    sudo dnf install -y code

    log "Installing IntelliJ IDEA Community..."
    flatpak install -y flathub com.jetbrains.IntelliJ-IDEA-Community || true
}

# ─── PHASE 6 — AI Tools ──────────────────────────────────────────────────────
phase6() {
    section "Phase 6 — AI Tools"

    log "Installing Claude Code CLI..."
    npm install -g @anthropic/claude-code

    if [ -n "${ANTHROPIC_API_KEY:-}" ]; then
        append_if_missing "export ANTHROPIC_API_KEY=\"${ANTHROPIC_API_KEY}\"" ~/.zshrc
        log "ANTHROPIC_API_KEY written to ~/.zshrc"
    else
        warn "ANTHROPIC_API_KEY not set — add manually: echo 'export ANTHROPIC_API_KEY=\"your-key\"' >> ~/.zshrc"
    fi

    log "Installing Obsidian..."
    flatpak install -y flathub md.obsidian.Obsidian || true

    log "Cloning SolutionByHour vault..."
    if [ ! -d "$HOME/SolutionByHour" ]; then
        git clone "git@github.com:${GITHUB_USERNAME}/SolutionByHour.git" ~/SolutionByHour || \
            warn "Vault clone failed — SSH key may not be set up yet. Clone manually after SSH setup."
    else
        info "Vault already exists at ~/SolutionByHour"
    fi
}

# ─── PHASE 7 — Gaming ────────────────────────────────────────────────────────
phase7() {
    section "Phase 7 — Gaming"

    log "Installing Steam..."
    flatpak install -y flathub com.valvesoftware.Steam || true

    log "Installing ProtonUp-Qt (GE-Proton manager)..."
    flatpak install -y flathub net.davidotek.pupgui2 || true

    log "Installing GameMode..."
    sudo dnf install -y gamemode

    log "Installing MangoHUD..."
    sudo dnf install -y mangohud

    log "Setting up game dock guard..."
    mkdir -p ~/.config/systemd/user
    cp "$FEDORA_TOOLS_DIR/game-dock-guard.sh" ~/Dev/game-dock-guard.sh
    chmod +x ~/Dev/game-dock-guard.sh
    cp "$FEDORA_TOOLS_DIR/game-dock-guard.service" ~/.config/systemd/user/game-dock-guard.service
    systemctl --user daemon-reload
    systemctl --user enable --now game-dock-guard.service
    log "Game dock guard enabled — dock hides for any Steam game"

    info "After Steam installs: Settings → Compatibility → Enable Steam Play for all titles → Proton Experimental"
    info "Open ProtonUp-Qt and install latest GE-Proton for: V Rising, KCD2, No Rest for the Wicked"
}

# ─── PHASE 8 — Productivity & Apps ───────────────────────────────────────────
phase8() {
    section "Phase 8 — Productivity & Apps"

    log "Installing Discord..."
    flatpak install -y flathub com.discordapp.Discord || true

    log "Installing Chrome..."
    sudo dnf install -y fedora-workstation-repositories || true
    sudo dnf config-manager --set-enabled google-chrome || true
    sudo dnf install -y google-chrome-stable || true

    log "Installing rclone (OneDrive access)..."
    sudo dnf install -y rclone
    warn "Run 'rclone config' manually to authenticate OneDrive"

    log "Installing Nautilus extras..."
    sudo dnf install -y nautilus-open-terminal || true

    log "Installing NordVPN..."
    sh <(curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh) -n || true
    sudo usermod -aG nordvpn "$USER" || true
    warn "NordVPN installed — run 'nordvpn login' to authenticate (log out first for group to take effect)"
}

# ─── MAIN ─────────────────────────────────────────────────────────────────────
main() {
    if [ -z "$GIT_NAME" ] || [ -z "$GIT_EMAIL" ] || [ -z "$GITHUB_USERNAME" ]; then
        echo -e "${RED}Missing required env vars. Set before running:${NC}"
        echo "  GIT_NAME=\"Your Name\" GIT_EMAIL=\"you@example.com\" GITHUB_USERNAME=\"yourhandle\" ./fedora-setup.sh"
        exit 1
    fi

    echo -e "${BLUE}"
    echo "  ┌─────────────────────────────────────────┐"
    echo "  │        Fedora Post-Install Setup         │"
    echo "  │  GIT_NAME  : $GIT_NAME"
    echo "  │  GIT_EMAIL : $GIT_EMAIL"
    echo "  │  GITHUB    : $GITHUB_USERNAME"
    echo "  └─────────────────────────────────────────┘"
    echo -e "${NC}"

    local target="${1:-all}"

    case "$target" in
        phase1) phase1 ;;
        phase2) phase2 ;;
        phase3) phase3 ;;
        phase4) phase4 ;;
        phase5) phase5 ;;
        phase6) phase6 ;;
        phase7) phase7 ;;
        phase8) phase8 ;;
        all)
            phase1
            warn "──────────────────────────────────────────"
            warn "Reboot now, then re-run: ./fedora-setup.sh post-reboot"
            warn "──────────────────────────────────────────"
            ;;
        post-reboot)
            phase2; phase3; phase4; phase5; phase6; phase7; phase8
            section "Setup Complete"
            log "All phases done."
            warn "Manual steps remaining:"
            echo "  1. gh auth login"
            echo "  2. ssh-keygen -t ed25519 -C $GIT_EMAIL  →  add to GitHub"
            echo "  3. Add ANTHROPIC_API_KEY to ~/.zshrc"
            echo "  4. Open Obsidian → select ~/SolutionByHour as vault"
            echo "  5. Open ProtonUp-Qt → install latest GE-Proton"
            echo "  6. Sign in to Steam"
            echo "  7. rclone config  →  authenticate OneDrive"
            ;;
        *)
            echo "Usage: $0 [phase1|phase2|phase3|phase4|phase5|phase6|phase7|phase8|all|post-reboot]"
            exit 1
            ;;
    esac
}

main "$@"
