# fedora-tools

Personal setup scripts and configs for Fedora Workstation. Built for a dev + gaming machine (AMD RX 6800, GNOME, Wayland).

## What's in here

| File | What it does |
|---|---|
| `fedora-setup.sh` | Full post-install setup script — runs all phases in order |
| `wezterm.lua` | WezTerm terminal config — GPU rendering, tmux-style keybinds, Catppuccin Mocha |
| `tiling-shell-setup.sh` | Installs Tiling Shell GNOME extension + applies 5 custom snap layouts |
| `game-dock-guard.sh` | Hides Dash to Dock while any Steam game is running, restores on exit |
| `game-dock-guard.service` | systemd user service to run game-dock-guard at login |

## Quick start (fresh Fedora install)

```bash
git clone https://github.com/shubhamkokul/fedora-tools.git ~/Dev/fedora-tools
cd ~/Dev/fedora-tools

# Phase 1 — system base (then reboot)
./fedora-setup.sh phase1

# After reboot — everything else
GIT_NAME="Your Name" GIT_EMAIL="you@example.com" GITHUB_USERNAME="yourhandle" ./fedora-setup.sh post-reboot
```

Optionally pass your Anthropic API key:
```bash
GIT_NAME="Your Name" GIT_EMAIL="you@example.com" GITHUB_USERNAME="yourhandle" ANTHROPIC_API_KEY="sk-..." ./fedora-setup.sh post-reboot
```

Run a single phase:
```bash
./fedora-setup.sh phase4   # dev tools only
./fedora-setup.sh phase7   # gaming only
```

---

## What gets installed

### Phase 1 — System base
- Full system update
- RPM Fusion (free + nonfree) — unlocks codecs, drivers, extra packages
- Flathub — app store for Flatpak apps
- GStreamer codecs + ffmpeg — video/audio playback
- GNOME Tweaks, Extension Manager, dconf-editor

### Phase 2 — Desktop
- **Tiling Shell** — Windows-style snap zones (5 custom layouts applied)
- **Dash to Dock** config — intellihide, autohide tuned to not interfere with normal use
- Papirus icon theme
- Bibata cursor theme

### Phase 3 — Terminal
- zsh + Oh My Zsh
- tmux, htop, btop, fzf, bat, eza, ripgrep, fd, jq, tree, neofetch
- JetBrains Mono font
- **WezTerm** (Flatpak) + config from this repo applied automatically

### Phase 4 — Dev tools
- git + git-lfs, GitHub CLI (`gh`)
- Java 21 (OpenJDK) + JAVA_HOME wired into ~/.zshrc
- Maven 3.9
- Node.js 22 via nvm
- Python 3 + pip + virtualenv
- Docker + docker-compose (service enabled, user added to docker group)
- kubectl
- PowerShell Core (pwsh)
- PostgreSQL 18 — installed, not initialized (run `postgresql-setup --initdb` when needed)
- pgAdmin4 (Flatpak)
- Grafana — installed, service disabled (start manually when needed)
- MongoDB 8.0 + mongosh — installed, service disabled (start manually when needed)

### Phase 5 — IDEs
- VS Code (RPM, official Microsoft repo)
- IntelliJ IDEA Community (Flatpak)

### Phase 6 — AI tools
- Claude Code CLI (`npm install -g @anthropic/claude-code`)
- Obsidian (Flatpak)
- SolutionByHour vault cloned from GitHub
- ANTHROPIC_API_KEY written to ~/.zshrc if provided

### Phase 7 — Gaming
- Steam (Flatpak)
- ProtonUp-Qt — GE-Proton version manager
- GameMode — CPU/GPU boost while gaming
- MangoHUD — FPS + hardware overlay
- **Game dock guard** — systemd service that hides the dock for any Steam game

### Phase 8 — Apps
- Discord (Flatpak)
- Google Chrome (RPM, official repo)
- rclone — OneDrive/cloud storage CLI
- nautilus-open-terminal — right-click → open terminal in Files

---

## What requires manual steps after running

| Step | Why it can't be automated |
|---|---|
| `gh auth login` | Interactive browser OAuth |
| `ssh-keygen` + add to GitHub | Key generation is interactive; adding requires GitHub access |
| Steam sign-in + enable Proton | GUI only |
| ProtonUp-Qt → install GE-Proton | GUI only |
| `rclone config` | Interactive OAuth flow |
| `ANTHROPIC_API_KEY` | Secret — pass as env var or add manually |
| `postgresql-setup --initdb` | One-time DB init, only when you need it |

---

## WezTerm

GPU-accelerated terminal with built-in multiplexing. Replaces GNOME Terminal + tmux.

### Install

```bash
flatpak install flathub org.wezfurlong.wezterm
mkdir -p ~/.config/wezterm
cp wezterm.lua ~/.config/wezterm/wezterm.lua
```

### Key bindings

Leader key: `CTRL+A`

| Keys | Action |
|---|---|
| `LEADER + \|` | Split pane vertically |
| `LEADER + -` | Split pane horizontally |
| `LEADER + h/j/k/l` | Navigate panes |
| `LEADER + H/J/K/L` | Resize pane |
| `LEADER + z` | Zoom/unzoom pane |
| `LEADER + c` | New tab |
| `LEADER + n / p` | Next / previous tab |
| `LEADER + x` | Close pane |
| `CTRL+C` | Copy if selected, else SIGINT |

---

## Tiling Shell

Windows-style snap zones for GNOME. Drag a window to trigger layout picker.

### Install

```bash
chmod +x tiling-shell-setup.sh
./tiling-shell-setup.sh
# Log out and back in to activate on Wayland
```

### Layouts

| Layout | Description |
|---|---|
| Two Portrait | 2x2 grid — screen split like two portrait monitors |
| Half & Half | Equal left/right halves |
| Top & Bottom | Equal top/bottom halves |
| Main + Side | 67/33 split |
| 3 Columns | Equal thirds |

---

## Game Dock Guard

Hides Dash to Dock on the primary monitor while any Steam game is running. Detects Steam's `reaper` process — fires for every game, not just one. On multi-monitor setups the dock stays on the secondary screen.

### Install

```bash
cp game-dock-guard.sh ~/Dev/game-dock-guard.sh
chmod +x ~/Dev/game-dock-guard.sh
mkdir -p ~/.config/systemd/user
cp game-dock-guard.service ~/.config/systemd/user/game-dock-guard.service
systemctl --user daemon-reload
systemctl --user enable --now game-dock-guard.service
```

Log: `~/.local/share/game-dock-guard.log`
