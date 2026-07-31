-- Hyprland Lua Configuration (v0.55+)

require("env")
require("plugins")
require("execs")

-- Workspaces
hl.workspace_rule({ workspace = "1", monitor = "DP-1", default = true })
for i = 2, 5 do
	hl.workspace_rule({ workspace = tostring(i), monitor = "DP-1" })
end
for i = 6, 10 do
	hl.workspace_rule({ workspace = tostring(i), monitor = "DP-4" })
end

-- Cursor & Device
hl.config({ cursor = { default_monitor = "DP-1" } })
hl.device({ name = "2.4g-dongle-2", kb_layout = "us" })

-- Input, Binds, General, Layouts, Decoration, Misc, XWayland
hl.config({
	input = {
		kb_layout = "br, us",
		kb_options = "grp:shift_caps_toggle",
		numlock_by_default = true,
		repeat_delay = 250,
		repeat_rate = 20,
		touchpad = {
			natural_scroll = true,
			disable_while_typing = true,
			clickfinger_behavior = true,
			scroll_factor = 0.5,
		},
		special_fallthrough = true,
	},
	binds = {
		scroll_event_delay = 0,
		allow_pin_fullscreen = true,
	},
	general = {
		gaps_in = 4,
		gaps_out = 5,
		gaps_workspaces = 50,
		border_size = 2,
		col = {
			active_border = "rgba(0DB7D4FF)",
			inactive_border = "rgba(31313600)",
		},
		resize_on_border = true,
		no_focus_fallback = true,
		layout = "dwindle",
		allow_tearing = true,
		snap = {
			enabled = true,
			window_gap = 15,
			monitor_gap = 30,
		},
	},
	dwindle = {
		smart_resizing = false,
		preserve_split = true,
	},
	master = {
		new_status = "inherit",
		new_on_top = true,
		allow_small_split = false,
		orientation = "left",
		always_keep_position = false,
	},
	decoration = {
		rounding = 5,
		blur = {
			enabled = true,
			xray = false,
			special = false,
			new_optimizations = true,
			size = 1,
			passes = 4,
			brightness = 1,
			noise = 0.01,
			contrast = 1,
		},
		shadow = {
			enabled = true,
			range = 25,
			offset = { 0, 2 },
			render_power = 2,
			color = "rgba(0000001A)",
		},
		dim_inactive = false,
		dim_strength = 0.1,
		dim_special = 0,
	},
	misc = {
		vrr = 1,
		focus_on_activate = true,
		animate_manual_resizes = true,
		animate_mouse_windowdragging = false,
		enable_swallow = false,
		swallow_regex = "(foot|kitty|allacritty|Alacritty)",
		middle_click_paste = false,
		key_press_enables_dpms = true,
		mouse_move_focuses_monitor = true,
		disable_hyprland_logo = true,
	},
	xwayland = {
		force_zero_scaling = true,
		use_nearest_neighbor = true,
		enabled = true,
	},
})

-- Sourced Modules
require("modules.rules")
require("modules.animations")

-- DMS (Migrated binds.conf)
require("dms.binds")

-- Essential & Pointer Keybinds
require("modules.essential_keybinds")
require("modules.kbptr_keybinds")
require("dms.outputs")
require("hyprland.colors")
