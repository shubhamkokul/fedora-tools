# wezterm-config

My personal [WezTerm](https://wezfurlong.org/wezterm/) configuration — built for engineers who live in the terminal.

## Why WezTerm

The terminal used to be a tool you visited. Now, with LLMs and tools like Claude Code, Copilot, and Aider, the terminal is where you *work* — running agents, reviewing diffs, prompting, iterating. That shift changed what I need from a terminal emulator.

GNOME Terminal was fine when the IDE did the heavy lifting. But when you're splitting panes to run an agent in one, watch logs in another, and edit files in a third — you need a terminal that keeps up.

WezTerm delivers:

- **GPU-accelerated rendering** — smooth at 120fps, no lag when tailing logs
- **Built-in multiplexing** — no separate tmux install, configured in Lua
- **Lua config** — your terminal settings are code: functions, conditionals, event hooks
- **Consistent across platforms** — Linux and macOS, same config file

## Setup

### Install WezTerm

**Fedora / RHEL:**
```bash
sudo dnf install wezterm
```

**macOS (Homebrew):**
```bash
brew install --cask wezterm
```

**Other:** See [wezfurlong.org/wezterm/installation](https://wezfurlong.org/wezterm/installation.html)

### Install font

This config uses [JetBrains Mono Nerd Font](https://www.nerdfonts.com/font-downloads).

```bash
# Fedora
sudo dnf install jetbrains-mono-fonts

# Then install the Nerd Font variant from nerdfonts.com
# and fc-cache -fv
```

### Apply config

```bash
mkdir -p ~/.config/wezterm
cp wezterm.lua ~/.config/wezterm/wezterm.lua
```

Restart WezTerm — changes apply immediately (live reload supported).

## Key Bindings

Leader key: `CTRL+A` (tmux-style)

| Keys | Action |
|---|---|
| `LEADER + \|` | Split pane vertically |
| `LEADER + -` | Split pane horizontally |
| `LEADER + h/j/k/l` | Navigate panes (vim-style) |
| `LEADER + H/J/K/L` | Resize pane |
| `LEADER + z` | Zoom/unzoom pane |
| `LEADER + c` | New tab |
| `LEADER + n / p` | Next / previous tab |
| `LEADER + 1-9` | Jump to tab by number |
| `LEADER + ,` | Rename tab |
| `LEADER + x` | Close pane |
| `LEADER + [` | Enter copy mode (scroll + select) |
| `LEADER + ]` | Paste from clipboard |
| `CTRL+C` | Copy if text selected, else send SIGINT |
| `CTRL+V` | Paste |
| `CTRL + =/-/0` | Increase / decrease / reset font size |
| `LEADER + u/d` | Scroll half page up / down |

## What's Configured

- **Color scheme:** Catppuccin Mocha
- **Font:** JetBrainsMono Nerd Font 13pt
- **Rendering:** WebGPU, 120fps max
- **Transparency:** 95% opacity
- **Inactive pane dimming:** desaturated + dimmed so focus is obvious
- **Cursor:** blinking bar
- **Status bar:** leader key indicator + live clock (bottom tab bar)
- **Scrollback:** 10,000 lines
- **Right-click:** paste

## Philosophy

Configured to feel like tmux without the overhead. If you already have tmux muscle memory, you'll be productive in under 5 minutes.

The Lua config is readable and self-documenting — hack it to fit your workflow.
