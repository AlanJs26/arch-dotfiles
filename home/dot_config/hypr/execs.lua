hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("systemctl --user start hyprland-session.target")
    hl.exec_cmd("systemctl --user start hypridle")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("dots health configure autostart_scripts_export")
    hl.exec_cmd("sleep 2 && dots autostart hyprland_programs --restart &>/tmp/autostart-once.log")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
end)

-- Executed on every config reload
hl.exec_cmd("dots autostart hyprland_programs &>/tmp/autostart.log")
hl.exec_cmd('gsettings set org.gnome.desktop.interface gtk-theme "TokyoNight"')
hl.exec_cmd('gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"')
