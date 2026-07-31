hl.config({
    plugin = {
        scroller = {
            window_default_height = "onehalf",
        },
    },
})

-- Move focus with mainMod + arrow keys
hl.bind("SUPER + h", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + l", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + k", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + j", hl.dsp.focus({ direction = "down" }))
hl.bind("SUPER + Home", hl.dsp.exec_cmd("hyprctl dispatch scroller:movefocus begin"))
hl.bind("SUPER + End", hl.dsp.exec_cmd("hyprctl dispatch scroller:movefocus end"))

-- Movement
hl.bind("SUPER + CTRL + h", hl.dsp.window.move({ direction = "l" }))
hl.bind("SUPER + CTRL + l", hl.dsp.window.move({ direction = "r" }))
hl.bind("SUPER + CTRL + k", hl.dsp.window.move({ direction = "u" }))
hl.bind("SUPER + CTRL + j", hl.dsp.window.move({ direction = "d" }))
hl.bind("SUPER + CTRL + Home", hl.dsp.exec_cmd("hyprctl dispatch scroller:movewindow begin"))
hl.bind("SUPER + CTRL + End", hl.dsp.exec_cmd("hyprctl dispatch scroller:movewindow end"))

-- Modes
hl.bind("SUPER + bracketleft", hl.dsp.exec_cmd("hyprctl dispatch scroller:setmode row"))
hl.bind("SUPER + bracketright", hl.dsp.exec_cmd("hyprctl dispatch scroller:setmode col"))

-- Set Mode Modifiers submap
hl.bind("SUPER + backslash", hl.dsp.submap("modifiers"))
hl.define_submap("modifiers", function()
    hl.bind("l", function()
        hl.dispatch(hl.dsp.exec_cmd("hyprctl dispatch scroller:setmodemodifier after"))
        hl.dispatch(hl.dsp.submap("reset"))
    end)
    hl.bind("h", function()
        hl.dispatch(hl.dsp.exec_cmd("hyprctl dispatch scroller:setmodemodifier before"))
        hl.dispatch(hl.dsp.submap("reset"))
    end)
    hl.bind("Home", function()
        hl.dispatch(hl.dsp.exec_cmd("hyprctl dispatch scroller:setmodemodifier beginning"))
        hl.dispatch(hl.dsp.submap("reset"))
    end)
    hl.bind("End", function()
        hl.dispatch(hl.dsp.exec_cmd("hyprctl dispatch scroller:setmodemodifier end"))
        hl.dispatch(hl.dsp.submap("reset"))
    end)
    hl.bind("k", function()
        hl.dispatch(hl.dsp.exec_cmd("hyprctl dispatch scroller:setmodemodifier , focus"))
        hl.dispatch(hl.dsp.submap("reset"))
    end)
    hl.bind("j", function()
        hl.dispatch(hl.dsp.exec_cmd("hyprctl dispatch scroller:setmodemodifier , nofocus"))
        hl.dispatch(hl.dsp.submap("reset"))
    end)
    hl.bind("2", function()
        hl.dispatch(hl.dsp.exec_cmd("hyprctl dispatch scroller:setmodemodifier , , auto, 2"))
        hl.dispatch(hl.dsp.submap("reset"))
    end)
    hl.bind("3", function()
        hl.dispatch(hl.dsp.exec_cmd("hyprctl dispatch scroller:setmodemodifier , , auto, 3"))
        hl.dispatch(hl.dsp.submap("reset"))
    end)
    hl.bind("m", function()
        hl.dispatch(hl.dsp.exec_cmd("hyprctl dispatch scroller:setmodemodifier , , manual"))
        hl.dispatch(hl.dsp.submap("reset"))
    end)
    hl.bind("escape", hl.dsp.submap("reset"))
end)

-- Sizing keys
hl.bind("SUPER + equal", hl.dsp.exec_cmd("hyprctl dispatch scroller:cyclewidth next"))
hl.bind("SUPER + minus", hl.dsp.exec_cmd("hyprctl dispatch scroller:cyclewidth prev"))
hl.bind("SUPER + SHIFT + equal", hl.dsp.exec_cmd("hyprctl dispatch scroller:cycleheight next"))
hl.bind("SUPER + SHIFT + minus", hl.dsp.exec_cmd("hyprctl dispatch scroller:cycleheight prev"))

-- Sizes submap
hl.bind("SUPER + b", hl.dsp.submap("sizing"))
hl.define_submap("sizing", function()
    local sizes = {
        ["1"] = "oneeighth", ["2"] = "onesixth", ["3"] = "onefourth",
        ["4"] = "onethird", ["5"] = "threeeighths", ["6"] = "onehalf",
        ["7"] = "fiveeighths", ["8"] = "twothirds", ["9"] = "threequarters",
        ["0"] = "fivesixths", ["minus"] = "seveneighths", ["equal"] = "one"
    }
    for k, v in pairs(sizes) do
        hl.bind(k, function()
            hl.dispatch(hl.dsp.exec_cmd("hyprctl dispatch scroller:setsize " .. v))
            hl.dispatch(hl.dsp.submap("reset"))
        end)
    end
    hl.bind("escape", hl.dsp.submap("reset"))
end)

-- Admit/Expel
hl.bind("SUPER + I", hl.dsp.exec_cmd("hyprctl dispatch scroller:admitwindow"))
hl.bind("SUPER + O", hl.dsp.exec_cmd("hyprctl dispatch scroller:expelwindow"))

-- Center submap
hl.bind("SUPER + C", hl.dsp.submap("center"))
hl.define_submap("center", function()
    local align_keys = { C = "c", m = "m", l = "r", h = "l", k = "u", j = "d" }
    for k, v in pairs(align_keys) do
        hl.bind(k, function()
            hl.dispatch(hl.dsp.exec_cmd("hyprctl dispatch scroller:alignwindow " .. v))
            hl.dispatch(hl.dsp.submap("reset"))
        end)
    end
    hl.bind("escape", hl.dsp.submap("reset"))
end)

-- Resize submap
hl.bind("SUPER + SHIFT + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    hl.bind("l", hl.dsp.window.resize({ size = {100, 0} }), { repeating = true })
    hl.bind("h", hl.dsp.window.resize({ size = {-100, 0} }), { repeating = true })
    hl.bind("k", hl.dsp.window.resize({ size = {0, -100} }), { repeating = true })
    hl.bind("j", hl.dsp.window.resize({ size = {0, 100} }), { repeating = true })
    hl.bind("escape", hl.dsp.submap("reset"))
end)

-- Fit size submap
hl.bind("SUPER + W", hl.dsp.submap("fitsize"))
hl.define_submap("fitsize", function()
    local fits = {
        W = "fitsize visible", l = "fitsize toend", h = "fitsize tobeg",
        k = "fitsize active", j = "fitsize all",
        bracketleft = "fitwidth all", bracketright = "fitheight all"
    }
    for k, v in pairs(fits) do
        hl.bind(k, function()
            hl.dispatch(hl.dsp.exec_cmd("hyprctl dispatch scroller:" .. v))
            hl.dispatch(hl.dsp.submap("reset"))
        end)
    end
    hl.bind("escape", hl.dsp.submap("reset"))
end)

-- Overview keys
hl.bind("SUPER + Tab", hl.dsp.exec_cmd("hyprctl dispatch scroller:toggleoverview"))
hl.bind("mouse:275", hl.dsp.exec_cmd("hyprctl dispatch scroller:toggleoverview"))

-- Marks
hl.bind("SUPER + M", hl.dsp.submap("marksadd"))
hl.define_submap("marksadd", function()
    for _, k in ipairs({"a", "b", "c"}) do
        hl.bind(k, function()
            hl.dispatch(hl.dsp.exec_cmd("hyprctl dispatch scroller:marksadd " .. k))
            hl.dispatch(hl.dsp.submap("reset"))
        end)
    end
    hl.bind("escape", hl.dsp.submap("reset"))
end)

hl.bind("SUPER + SHIFT + M", hl.dsp.submap("marksdelete"))
hl.define_submap("marksdelete", function()
    for _, k in ipairs({"a", "b", "c"}) do
        hl.bind(k, function()
            hl.dispatch(hl.dsp.exec_cmd("hyprctl dispatch scroller:marksdelete " .. k))
            hl.dispatch(hl.dsp.submap("reset"))
        end)
    end
    hl.bind("escape", hl.dsp.submap("reset"))
end)

hl.bind("SUPER + apostrophe", hl.dsp.submap("marksvisit"))
hl.define_submap("marksvisit", function()
    for _, k in ipairs({"a", "b", "c"}) do
        hl.bind(k, function()
            hl.dispatch(hl.dsp.exec_cmd("hyprctl dispatch scroller:marksvisit " .. k))
            hl.dispatch(hl.dsp.submap("reset"))
        end)
    end
    hl.bind("escape", hl.dsp.submap("reset"))
end)

hl.bind("SUPER + CTRL + M", hl.dsp.exec_cmd("hyprctl dispatch scroller:marksreset"))
hl.bind("SUPER + P", hl.dsp.exec_cmd("hyprctl dispatch scroller:pin"))

-- Window copy/paste
hl.bind("SUPER + Insert", hl.dsp.exec_cmd("hyprctl dispatch scroller:selectiontoggle"))
hl.bind("SUPER + CTRL + Insert", hl.dsp.exec_cmd("hyprctl dispatch scroller:selectionreset"))
hl.bind("SUPER + SHIFT + Insert", hl.dsp.exec_cmd("hyprctl dispatch scroller:selectionmove l"))
hl.bind("SUPER + CTRL + SHIFT + Insert", hl.dsp.exec_cmd("hyprctl dispatch scroller:selectionworkspace"))

-- Trails and Trailmarks
hl.bind("SUPER + SHIFT + semicolon", hl.dsp.submap("trail"))
hl.define_submap("trail", function()
    hl.bind("bracketright", hl.dsp.exec_cmd("hyprctl dispatch scroller:trailnext"))
    hl.bind("bracketleft", hl.dsp.exec_cmd("hyprctl dispatch scroller:trailprevious"))
    hl.bind("semicolon", function()
        hl.dispatch(hl.dsp.exec_cmd("hyprctl dispatch scroller:trailnew"))
        hl.dispatch(hl.dsp.submap("reset"))
    end)
    hl.bind("d", function()
        hl.dispatch(hl.dsp.exec_cmd("hyprctl dispatch scroller:traildelete"))
        hl.dispatch(hl.dsp.submap("reset"))
    end)
    hl.bind("c", function()
        hl.dispatch(hl.dsp.exec_cmd("hyprctl dispatch scroller:trailclear"))
        hl.dispatch(hl.dsp.submap("reset"))
    end)
    hl.bind("Insert", function()
        hl.dispatch(hl.dsp.exec_cmd("hyprctl dispatch scroller:trailtoselection"))
        hl.dispatch(hl.dsp.submap("reset"))
    end)
    hl.bind("escape", hl.dsp.submap("reset"))
end)

hl.bind("SUPER + semicolon", hl.dsp.submap("trailmark"))
hl.define_submap("trailmark", function()
    hl.bind("bracketright", hl.dsp.exec_cmd("hyprctl dispatch scroller:trailmarknext"))
    hl.bind("bracketleft", hl.dsp.exec_cmd("hyprctl dispatch scroller:trailmarkprevious"))
    hl.bind("semicolon", function()
        hl.dispatch(hl.dsp.exec_cmd("hyprctl dispatch scroller:trailmarktoggle"))
        hl.dispatch(hl.dsp.submap("reset"))
    end)
    hl.bind("escape", hl.dsp.submap("reset"))
end)

hl.bind("SUPER + slash", hl.dsp.exec_cmd("hyprctl dispatch scroller:jump"))
