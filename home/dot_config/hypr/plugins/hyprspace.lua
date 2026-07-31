hl.bind("ALT + apostrophe", hl.dsp.exec_cmd("hyprctl dispatch overview:toggle"))

hl.config({
    plugin = {
        overview = {
            showEmptyWorkspace = false,
            autoScroll = true,
            disableGestures = true,
            exitOnSwitch = true,
            exitOnClick = true,
            switchOnDrop = true,
            autoDrag = true,
            affectStrut = false,
            hideRealLayers = false,
            reservedArea = 30,
        },
    },
})
