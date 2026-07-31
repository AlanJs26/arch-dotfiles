hl.on("hyprland.start", function()
    hl.exec_cmd("sleep 2 && hyprpm reload -n")
end)

-- require("plugins.hyprscroller")
-- require("plugins.hyprexpo")
require("plugins.dynamic-cursors")
-- require("plugins.hyprspace")
