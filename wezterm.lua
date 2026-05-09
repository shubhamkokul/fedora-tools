local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

-- ── Rendering ─────────────────────────────────────────────────────────────────
config.front_end = 'WebGpu'
config.max_fps = 120
config.animation_fps = 60

-- ── Font ─────────────────────────────────────────────────────────────────────
config.font = wezterm.font('JetBrainsMono Nerd Font', { weight = 'Regular' })
config.font_size = 13.0
config.line_height = 1.1
config.freetype_load_flags = 'DEFAULT'

-- ── Color scheme ─────────────────────────────────────────────────────────────
config.color_scheme = 'Catppuccin Mocha'

-- ── Window ───────────────────────────────────────────────────────────────────
config.window_padding = { left = 8, right = 8, top = 4, bottom = 4 }
config.window_decorations = 'TITLE | RESIZE'
config.initial_cols = 115
config.initial_rows = 30
config.scrollback_lines = 10000
config.audible_bell = 'Disabled'
config.window_close_confirmation = 'NeverPrompt'
config.window_background_opacity = 0.95

-- ── Cursor ────────────────────────────────────────────────────────────────────
config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 500
config.cursor_blink_ease_in = 'Constant'
config.cursor_blink_ease_out = 'Constant'

-- ── Inactive pane dimming ─────────────────────────────────────────────────────
config.inactive_pane_hsb = {
  saturation = 0.7,
  brightness = 0.6,
}

-- ── Tab bar ──────────────────────────────────────────────────────────────────
config.enable_tab_bar = true
config.use_fancy_tab_bar = false               -- plain tmux-style bar
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = false
config.tab_max_width = 32
config.show_new_tab_button_in_tab_bar = false

-- ── Status bar — leader indicator + clock ─────────────────────────────────────
-- set_right_status is unreliable in retro tab bar mode; clock lives on the left
config.status_update_interval = 1000

wezterm.on('update-status', function(window, _)
  local leader = window:leader_is_active() and ' 󰌋 WAIT  ' or ''
  local time   = wezterm.strftime '%H:%M'

  window:set_left_status(wezterm.format {
    { Foreground = { AnsiColor = 'Yellow' } },
    { Text       = leader },
    { Foreground = { AnsiColor = 'BrightBlack' } },
    { Text       = ' ' .. time .. ' ' },
  })
end)

-- ── Leader key (CTRL+A, like tmux) ───────────────────────────────────────────
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }

-- ── Key bindings ─────────────────────────────────────────────────────────────
config.keys = {

  -- Pass CTRL+A through on double-tap
  { key = 'a', mods = 'LEADER', action = act.SendKey { key = 'a', mods = 'CTRL' } },

  -- ── Splits ─────────────────────────────────────────────────────────────────
  { key = '\\', mods = 'LEADER', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '-',  mods = 'LEADER', action = act.SplitVertical   { domain = 'CurrentPaneDomain' } },

  -- ── Pane navigation (vim keys) ─────────────────────────────────────────────
  { key = 'h', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },

  -- Arrow key navigation
  { key = 'LeftArrow',  mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
  { key = 'DownArrow',  mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
  { key = 'UpArrow',    mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
  { key = 'RightArrow', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },

  -- ── Pane resize ────────────────────────────────────────────────────────────
  { key = 'H', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize { 'Left', 5 } },
  { key = 'J', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize { 'Down', 5 } },
  { key = 'K', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize { 'Up', 5 } },
  { key = 'L', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize { 'Right', 5 } },

  -- ── Zoom / fullscreen pane ─────────────────────────────────────────────────
  { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },

  -- ── Tabs ───────────────────────────────────────────────────────────────────
  { key = 'c', mods = 'LEADER', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'n', mods = 'LEADER', action = act.ActivateTabRelative(1) },
  { key = 'p', mods = 'LEADER', action = act.ActivateTabRelative(-1) },

  -- Jump to tab by number
  { key = '1', mods = 'LEADER', action = act.ActivateTab(0) },
  { key = '2', mods = 'LEADER', action = act.ActivateTab(1) },
  { key = '3', mods = 'LEADER', action = act.ActivateTab(2) },
  { key = '4', mods = 'LEADER', action = act.ActivateTab(3) },
  { key = '5', mods = 'LEADER', action = act.ActivateTab(4) },
  { key = '6', mods = 'LEADER', action = act.ActivateTab(5) },
  { key = '7', mods = 'LEADER', action = act.ActivateTab(6) },
  { key = '8', mods = 'LEADER', action = act.ActivateTab(7) },
  { key = '9', mods = 'LEADER', action = act.ActivateTab(8) },

  -- Rename tab
  { key = ',', mods = 'LEADER', action = act.PromptInputLine {
    description = 'Rename tab:',
    action = wezterm.action_callback(function(window, _, line)
      if line then window:active_tab():set_title(line) end
    end),
  }},

  -- ── Close ──────────────────────────────────────────────────────────────────
  { key = 'x', mods = 'LEADER', action = act.CloseCurrentPane { confirm = false } },
  { key = '&', mods = 'LEADER|SHIFT', action = act.CloseCurrentTab { confirm = false } },

  -- ── Copy mode (like tmux scroll/copy) ─────────────────────────────────────
  { key = '[', mods = 'LEADER', action = act.ActivateCopyMode },

  -- ── Clipboard ──────────────────────────────────────────────────────────────
  { key = ']', mods = 'LEADER', action = act.PasteFrom 'Clipboard' },
  -- CTRL+C: copy if selection active, otherwise send SIGINT
  { key = 'c', mods = 'CTRL', action = wezterm.action_callback(function(window, pane)
      if window:get_selection_text_for_pane(pane) ~= '' then
        window:perform_action(act.CopyTo 'Clipboard', pane)
      else
        window:perform_action(act.SendKey { key = 'c', mods = 'CTRL' }, pane)
      end
    end)
  },
  { key = 'v', mods = 'CTRL', action = act.PasteFrom 'Clipboard' },

  -- ── Scrollback ─────────────────────────────────────────────────────────────
  { key = 'u', mods = 'LEADER', action = act.ScrollByPage(-0.5) },
  { key = 'd', mods = 'LEADER', action = act.ScrollByPage(0.5) },

  -- ── Font size ──────────────────────────────────────────────────────────────
  { key = '=', mods = 'CTRL', action = act.IncreaseFontSize },
  { key = '-', mods = 'CTRL', action = act.DecreaseFontSize },
  { key = '0', mods = 'CTRL', action = act.ResetFontSize },
}

-- ── Mouse ────────────────────────────────────────────────────────────────────
config.mouse_bindings = {
  {
    event = { Down = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = act.PasteFrom 'Clipboard',
  },
}

return config
