hl.config({
    general = {
        col = {
            active_border = "rgba(b1c6ffAA)",
            inactive_border = "rgba(44464fAA)",
        },
    },
    misc = {
        background_color = "rgba(121318FF)",
    },
    plugin = {
        hyprbars = {
            bar_text_font = "Rubik, Geist, AR One Sans, Reddit Sans, Inter, Roboto, Ubuntu, Noto Sans, sans-serif",
            bar_height = 30,
            bar_padding = 10,
            bar_button_padding = 5,
            bar_precedence_over_border = true,
            bar_part_of_window = true,
            bar_color = "rgba(121318FF)",
            col = {
                text = "rgba(e2e2e9FF)",
            },
            ["hyprbars-button"] = {
                "rgb(e2e2e9), 13, 󰖭, hyprctl dispatch closewindow",
                "rgb(e2e2e9), 13, 󰖯, hyprctl dispatch fullscreen 1",
                "rgb(e2e2e9), 13, 󰖰, hyprctl dispatch movetoworkspacesilent special",
            },
        },
    },
})

hl.window_rule({ match = { pin = true }, border_color = "rgba(b1c6ffAA) rgba(b1c6ff77)" })
