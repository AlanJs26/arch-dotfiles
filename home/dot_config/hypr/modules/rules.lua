-- Workspace rules
hl.workspace_rule({ workspace = "w[tv1]f[-1]s[false]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "w[tg1]s[false]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]s[false]", gaps_out = 20, border_size = 4 })

-- Window rules
hl.window_rule({ match = { workspace = "w[tv1]f[-1]s[false]" }, border_size = 0 })
hl.window_rule({ match = { float = true }, border_size = 2 })

-- Dialog windows
local dialog_titles = {
	"^(Open File)(.*)$",
	"^(Select a File)(.*)$",
	"^(Choose wallpaper)(.*)$",
	"^(Open Folder)(.*)$",
	"^(Save As)(.*)$",
	"^(Library)(.*)$",
	"^(File Upload)(.*)$",
}
for _, t in ipairs(dialog_titles) do
	hl.window_rule({ match = { title = t }, center = true, float = true })
end

-- Steam
hl.window_rule({
	match = { class = "^([Ss]team)$", title = "^(Steam Big Picture Mode)$" },
	suppress_event = "fullscreen",
})
hl.window_rule({
	match = { class = "^([Ss]team)$", title = "^(Steam Big Picture Mode)$" },
	fullscreen = true,
	no_anim = true,
	sync_fullscreen = true,
	center = true,
})
hl.window_rule({
	match = { class = "^([Ss]team)$", title = "^(Friends List)$" },
	float = true,
	center = true,
	size = "20% 80%",
})

-- VS Code
hl.window_rule({ match = { float = true }, center = true })

-- Matlab
hl.window_rule({ match = { class = ".*MATLAB.*", title = "(Opening\\.\\.\\.|^Figure.*)" }, float = true })

-- Floating
hl.window_rule({ match = { class = "^(org.gnome.Nautilus)$" }, float = true })
hl.window_rule({ match = { class = "^(blueberry\\.py)$" }, float = true })
hl.window_rule({ match = { class = "^(guifetch)$" }, float = true })
hl.window_rule({ match = { class = "^(kitty-scratchpad)$" }, float = true, size = "80% 60" })
hl.window_rule({ match = { class = "^(qalculate-gtk)$" }, float = true })
hl.window_rule({ match = { class = "^(pavucontrol)$" }, float = true, center = true })
hl.window_rule({ match = { class = "^(org.pulseaudio.pavucontrol)$" }, float = true, center = true })
hl.window_rule({ match = { class = "^(nm-connection-editor)$" }, float = true, center = true })
hl.window_rule({ match = { class = ".*plasmawindowed.*" }, float = true })
hl.window_rule({ match = { class = "kcm_.*" }, float = true })
hl.window_rule({ match = { class = "(^__float__$)" }, float = true, center = true })
hl.window_rule({ match = { class = "(^com.github.th-ch.youtube-music$)" }, float = true })
hl.window_rule({ match = { class = "(^nemo$)" }, float = true, center = true })
hl.window_rule({ match = { class = ".*bluedevilwizard" }, float = true })
hl.window_rule({ match = { title = ".*Welcome" }, float = true })
hl.window_rule({ match = { title = "^(illogical-impulse Settings)$" }, float = true })
hl.window_rule({ match = { class = "org.freedesktop.impl.portal.desktop.kde" }, float = true })
hl.window_rule({ match = { class = "com-azefsw-audioconnect-desktop-app-MainKt" }, float = true })
hl.window_rule({ match = { title = "^(Bitwarden - Vivaldi)$" }, float = true })
hl.window_rule({ match = { class = "^(Scangearmp2)$" }, float = true, center = true })

-- Misc
hl.window_rule({ match = { class = "(judo-chaves-svelte)" }, suppress_event = "activatefocus" })
hl.window_rule({ match = { class = "(Webots)" }, suppress_event = "activatefocus", workspace = "7" })

-- Picture-in-Picture
hl.window_rule({
	match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" },
	float = true,
	keep_aspect_ratio = true,
	move = "73% 72%",
	pin = true,
})

-- Layer rules
hl.layer_rule({ match = { namespace = ".*" }, xray = true })

local no_anim_namespaces = {
	"walker",
	"selection",
	"overview",
	"anyrun",
	"indicator.*",
	"osk",
	"hyprpicker",
	"noanim",
}
for _, ns in ipairs(no_anim_namespaces) do
	hl.layer_rule({ match = { namespace = ns }, no_anim = true })
end
hl.layer_rule({ match = { namespace = "noanim" }, blur = true })

hl.layer_rule({ match = { namespace = "gtk-layer-shell" }, blur = true })
hl.layer_rule({ match = { namespace = "launcher" }, blur = true, ignore_alpha = 0.5 })
hl.layer_rule({ match = { namespace = "notifications" }, blur = true, ignore_alpha = 0.69 })
hl.layer_rule({ match = { namespace = "logout_dialog" }, blur = true })

-- Quickshell layer rules
hl.layer_rule({ match = { namespace = "quickshell:.*" }, blur_popups = true, blur = true, ignore_alpha = 0.79 })
hl.layer_rule({ match = { namespace = "quickshell:bar" }, animation = "slide" })
hl.layer_rule({ match = { namespace = "quickshell:screenCorners" }, animation = "fade" })
hl.layer_rule({ match = { namespace = "quickshell:sidebarRight" }, animation = "slide right" })
hl.layer_rule({ match = { namespace = "quickshell:sidebarLeft" }, animation = "slide left" })
hl.layer_rule({ match = { namespace = "quickshell:osk" }, animation = "slide bottom" })
hl.layer_rule({ match = { namespace = "quickshell:dock" }, animation = "slide bottom" })
hl.layer_rule({ match = { namespace = "quickshell:session" }, blur = true, no_anim = true, ignore_alpha = 0 })
hl.layer_rule({ match = { namespace = "quickshell:notificationPopup" }, animation = "fade" })
hl.layer_rule({ match = { namespace = "quickshell:backgroundWidgets" }, blur = true, ignore_alpha = 0.05 })
hl.layer_rule({ match = { namespace = "quickshell:screenshot" }, no_anim = true })
hl.layer_rule({ match = { namespace = "quickshell:screenCorners" }, animation = "popin 120%" })

-- Launchers
hl.layer_rule({ match = { namespace = "quickshell:overview" }, no_anim = true })
hl.layer_rule({ match = { namespace = "gtk4-layer-shell" }, no_anim = true })
hl.layer_rule({ match = { namespace = "swaylock" }, blur = true })
hl.layer_rule({ match = { namespace = "eww" }, blur = true, ignore_alpha = 0.8 })
