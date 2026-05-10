#!/bin/bash
# Hides Dash to Dock while any Steam game is running.
# On multi-monitor setups the dock stays on the secondary screen.
# On single monitor it disables entirely.
# Detection: Steam's 'reaper' process — present for any running game, gone on exit.

DOCK_ID="dash-to-dock@micxgx.gmail.com"
GAME_ACTIVE=false
LOG="$HOME/.local/share/game-dock-guard.log"

log() { echo "[$(date '+%H:%M:%S')] $*" >> "$LOG"; }

ORIG_MULTI=$(gsettings get org.gnome.shell.extensions.dash-to-dock multi-monitor)
ORIG_PREFERRED=$(gsettings get org.gnome.shell.extensions.dash-to-dock preferred-monitor)
ORIG_CONNECTOR=$(gsettings get org.gnome.shell.extensions.dash-to-dock preferred-monitor-by-connector)

log "Started — multi=$ORIG_MULTI preferred=$ORIG_PREFERRED connector=$ORIG_CONNECTOR"

is_game_running() {
    pgrep -x "reaper" > /dev/null 2>&1
}

get_secondary_connector() {
    xrandr 2>/dev/null | awk '/ connected/ && !/primary/ {print $1; exit}'
}

game_started() {
    log "Game detected — hiding dock"
    local secondary
    secondary=$(get_secondary_connector)

    if [ -n "$secondary" ]; then
        log "Multi-monitor: moving dock to $secondary"
        gsettings set org.gnome.shell.extensions.dash-to-dock multi-monitor false
        gsettings set org.gnome.shell.extensions.dash-to-dock preferred-monitor-by-connector "$secondary"
    else
        log "Single monitor: disabling dock"
        gnome-extensions disable "$DOCK_ID"
    fi
}

game_stopped() {
    log "Game exited — restoring dock"
    gnome-extensions enable "$DOCK_ID"
    gsettings set org.gnome.shell.extensions.dash-to-dock multi-monitor "$ORIG_MULTI"
    gsettings set org.gnome.shell.extensions.dash-to-dock preferred-monitor "$ORIG_PREFERRED"
    gsettings set org.gnome.shell.extensions.dash-to-dock preferred-monitor-by-connector "$ORIG_CONNECTOR"
}

while true; do
    if is_game_running; then
        if [ "$GAME_ACTIVE" = false ]; then
            GAME_ACTIVE=true
            game_started
        fi
    else
        if [ "$GAME_ACTIVE" = true ]; then
            GAME_ACTIVE=false
            game_stopped
        fi
    fi
    sleep 5
done
