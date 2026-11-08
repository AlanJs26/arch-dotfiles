local mainMod = "SUPER"

-- Special workspace & tools
-- hl.bind(mainMod .. " + I", hl.dsp.workspace.toggle_special("magic"))
-- hl.bind(mainMod .. " + SHIFT + I", hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind(mainMod .. " + U", hl.dsp.exec_cmd("wayscriber --daemon-toggle"))

-- Monitors
hl.bind(mainMod .. " + O", hl.dsp.focus({ monitor = "+1" }))
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.workspace.swap_monitors({ monitor1 = "current", monitor2 = "+1" }))
hl.bind(mainMod .. " + SHIFT + O", hl.dsp.workspace.swap_monitors({ monitor1 = "current", monitor2 = "+1" }))

-- Screen / Zoom
hl.bind(
	mainMod .. " + SHIFT + Minus",
	hl.dsp.exec_cmd("~/.config/hypr/modules/scripts/zoom.sh decrease 0.1"),
	{ repeating = true }
)
hl.bind(
	mainMod .. " + SHIFT + Equal",
	hl.dsp.exec_cmd("~/.config/hypr/modules/scripts/zoom.sh increase 0.1"),
	{ repeating = true }
)
hl.bind(mainMod .. " + SHIFT + mouse_down", hl.dsp.exec_cmd("~/.config/hypr/modules/scripts/zoom.sh decrease 0.1"))
hl.bind(mainMod .. " + SHIFT + mouse_up", hl.dsp.exec_cmd("~/.config/hypr/modules/scripts/zoom.sh increase 0.1"))

-- Windows
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + S", hl.dsp.window.float({ action = "toggle" }))

local has_hyprnavi = false
local handle = io.popen("which hyprnavi")
if handle then
	has_hyprnavi = handle:read("*a") ~= ""
	handle:close()
end

if has_hyprnavi then
	hl.bind(mainMod .. " + SHIFT + H", hl.dsp.exec_cmd("hyprnavi l --swap --bordersize 10"))
	hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("hyprnavi r --swap --bordersize 10"))
	hl.bind(mainMod .. " + SHIFT + K", hl.dsp.exec_cmd("hyprnavi u --swap"))
	hl.bind(mainMod .. " + SHIFT + J", hl.dsp.exec_cmd("hyprnavi d --swap"))

	hl.bind(mainMod .. " + H", hl.dsp.exec_cmd("hyprnavi l"))
	hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprnavi r"))

	hl.bind(mainMod .. " + K", hl.dsp.exec_cmd("hyprnavi u"))
	hl.bind(mainMod .. " + K", hl.dsp.group.next())

	hl.bind(mainMod .. " + J", hl.dsp.exec_cmd("hyprnavi d"))
	hl.bind(mainMod .. " + J", hl.dsp.group.prev())
else
	hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.swap({ direction = "l" }))
	hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.swap({ direction = "r" }))
	hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.swap({ direction = "u" }))
	hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.swap({ direction = "d" }))

	hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "l" }))
	hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "r" }))
	hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "u" }))
	hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "d" }))
end

hl.bind(mainMod .. " + SHIFT + Left", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + Right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + Up", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + Down", hl.dsp.window.move({ direction = "d" }))

hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("$HOME/.scripts/hyprland-scripts/keybind-cycle-master-width.sh"))
hl.bind(
	mainMod .. " + SHIFT + W",
	hl.dsp.exec_cmd("$HOME/.scripts/hyprland-scripts/keybind-cycle-master-width.sh vertical")
)

hl.bind(
	mainMod .. " + SHIFT + CTRL + H",
	hl.dsp.window.resize({ relative = true, x = -40, y = 0 }),
	{ repeating = true }
)
hl.bind(
	mainMod .. " + SHIFT + CTRL + L",
	hl.dsp.window.resize({ relative = true, x = 40, y = 0 }),
	{ repeating = true }
)
hl.bind(
	mainMod .. " + SHIFT + CTRL + K",
	hl.dsp.window.resize({ relative = true, x = 0, y = -40 }),
	{ repeating = true }
)
hl.bind(
	mainMod .. " + SHIFT + CTRL + J",
	hl.dsp.window.resize({ relative = true, x = 0, y = 40 }),
	{ repeating = true }
)

hl.bind(mainMod .. " + E", hl.dsp.group.toggle())

hl.bind(mainMod .. " + Left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + Right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + Up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + Down", hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + SHIFT + ccedilla", hl.dsp.window.center())
hl.bind(mainMod .. " + ccedilla", hl.dsp.window.center())
hl.bind(mainMod .. " + code:47", hl.dsp.window.center())

hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen_state({ internal = 2, client = 2 }))
hl.bind(mainMod .. " + A", hl.dsp.window.fullscreen_state({ internal = 1, client = -1 }))
hl.bind(mainMod .. " + SHIFT + A", hl.dsp.window.fullscreen_state({ internal = -1, client = 2 }))

-- App cycling
hl.bind(
	mainMod .. " + 1",
	hl.dsp.exec_cmd("$HOME/.scripts/hyprland-scripts/cycle-apps.nu class:kitty -or class:code --by-workspace")
)
hl.bind(
	mainMod .. " + 2",
	hl.dsp.exec_cmd("$HOME/.scripts/hyprland-scripts/cycle-apps.nu class:vivaldi --by-workspace")
)
hl.bind(
	mainMod .. " + 3",
	hl.dsp.exec_cmd("$HOME/.scripts/hyprland-scripts/cycle-apps.nu class:obsidian -or class:sioyek --by-workspace")
)
hl.bind(
	mainMod .. " + 4",
	hl.dsp.exec_cmd("$HOME/.scripts/hyprland-scripts/cycle-apps.nu class:vesktop -or class:discord --by-workspace")
)

hl.bind(
	mainMod .. " + CTRL + 1",
	hl.dsp.exec_cmd("$HOME/.scripts/hyprland-scripts/cycle-apps.nu class:kitty -or class:code --bring-window")
)
hl.bind(
	mainMod .. " + CTRL + 2",
	hl.dsp.exec_cmd("$HOME/.scripts/hyprland-scripts/cycle-apps.nu class:vivaldi --bring-window")
)
hl.bind(
	mainMod .. " + CTRL + 3",
	hl.dsp.exec_cmd("$HOME/.scripts/hyprland-scripts/cycle-apps.nu class:obsidian -or class:sioyek --bring-window")
)
hl.bind(
	mainMod .. " + CTRL + 4",
	hl.dsp.exec_cmd("$HOME/.scripts/hyprland-scripts/cycle-apps.nu class:vesktop -or class:discord --bring-window")
)

-- Workspaces
hl.bind(mainMod .. " + Tab", hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mainMod .. " + SHIFT + Tab", hl.dsp.focus({ workspace = "m-1" }))
hl.bind(mainMod .. " + ALT + Tab", hl.dsp.window.move({ workspace = "m+1" }))
hl.bind(mainMod .. " + ALT + SHIFT + Tab", hl.dsp.window.move({ workspace = "m-1" }))

-- hl.bind(mainMod .. " + Apostrophe", hl.dsp.focus({ workspace = "emptym" }))
-- hl.bind(mainMod .. " + ALT + Apostrophe", hl.dsp.window.move({ workspace = "emptym" }))
-- hl.bind(mainMod .. " + SHIFT + Apostrophe", hl.dsp.window.move({ workspace = "emptym", follow = false }))
hl.bind(mainMod .. " + code:48", hl.dsp.focus({ workspace = "emptym" }))
hl.bind(mainMod .. " + ALT + code:48", hl.dsp.window.move({ workspace = "emptym" }))
hl.bind(mainMod .. " + SHIFT + code:48", hl.dsp.window.move({ workspace = "emptym", follow = false }))
hl.bind(mainMod .. " + code:49", hl.dsp.focus({ workspace = "emptym" }))
hl.bind(mainMod .. " + ALT + code:49", hl.dsp.window.move({ workspace = "emptym" }))
hl.bind(mainMod .. " + SHIFT + code:49", hl.dsp.window.move({ workspace = "emptym", follow = false }))

-- Workspaces 1..10
for i = 1, 10 do
	local key = tostring(i % 10)
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + ALT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Programs & Scratchpads
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("dots launch terminal"))
hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.exec_cmd("dots launch browser"))

hl.bind(mainMod .. " + CTRL + backslash", hl.dsp.exec_cmd("hypad toggle calc"))
hl.bind(mainMod .. " + CTRL + Z", hl.dsp.exec_cmd("hypad toggle music"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("hypad toggle audiorelay"))
hl.bind(mainMod .. " + SHIFT + Z", hl.dsp.exec_cmd("hypad toggle terminal"))
hl.bind("XF86Search", hl.dsp.exec_cmd("hypad toggle pavucontrol"))
hl.bind(mainMod .. " + CTRL + X", hl.dsp.exec_cmd("hypad toggle filemanager"))

hl.bind("XF86Calculator", hl.dsp.exec_cmd("~/.scripts/tools/cycle-audio-devices.nu"), { locked = true })
hl.bind("SHIFT + XF86Calculator", hl.dsp.exec_cmd("~/.scripts/tools/cycle-audio-devices.nu port"), { locked = true })

-- Rofi
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("~/.scripts/rofi-scripts/rofi-all.sh"))
hl.bind(mainMod .. " + CTRL + Space", hl.dsp.exec_cmd("~/.scripts/rofi-scripts/rofi-zoxide.sh"))
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd("pgrep qs || rofi -show drun"))
hl.bind(
	mainMod .. " + SHIFT + E",
	hl.dsp.exec_cmd(
		'pgrep qs || rofi -show power-menu -modi "power-menu:~/.local/bin/rofi-power-menu --choices=lockscreen/shutdown/reboot/logout/suspend/hibernate"'
	)
)

if hl.get_config("general.layout") == "master" then
	-- Master Layout
	hl.bind(mainMod .. " + D", hl.dsp.layout("swapwithmaster"))
	hl.bind(mainMod .. " + Equal", hl.dsp.layout("addmaster"))
	hl.bind(mainMod .. " + Minus", hl.dsp.layout("removemaster"))

	hl.bind(mainMod .. " + bracketleft", hl.dsp.layout("rollnext"))
	hl.bind(mainMod .. " + bracketright", hl.dsp.layout("rollprev"))
end

hl.bind(
	mainMod .. " + CTRL + Left",
	hl.dsp.exec_cmd("$HOME/.scripts/hyprland-scripts/keybind-change-orientation.nu left")
)
hl.bind(
	mainMod .. " + CTRL + Right",
	hl.dsp.exec_cmd("$HOME/.scripts/hyprland-scripts/keybind-change-orientation.nu right")
)
hl.bind(
	mainMod .. " + CTRL + Down",
	hl.dsp.exec_cmd("$HOME/.scripts/hyprland-scripts/keybind-change-orientation.nu center")
)
hl.bind(mainMod .. " + CTRL + Up", hl.dsp.exec_cmd("$HOME/.scripts/hyprland-scripts/keybind-change-orientation.nu top"))

hl.bind(mainMod .. " + CTRL + H", hl.dsp.exec_cmd("$HOME/.scripts/hyprland-scripts/keybind-change-orientation.nu left"))
hl.bind(
	mainMod .. " + CTRL + L",
	hl.dsp.exec_cmd("$HOME/.scripts/hyprland-scripts/keybind-change-orientation.nu right")
)
hl.bind(
	mainMod .. " + CTRL + J",
	hl.dsp.exec_cmd("$HOME/.scripts/hyprland-scripts/keybind-change-orientation.nu center")
)
hl.bind(mainMod .. " + CTRL + K", hl.dsp.exec_cmd("$HOME/.scripts/hyprland-scripts/keybind-change-orientation.nu top"))

-- Hyprland
hl.bind(mainMod .. " + ALT + R", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mainMod .. " + SHIFT + ALT + R", hl.dsp.exec_cmd("dots autostart hyprland_programs --restart"))

-- Mouse move/resize
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
