-- Plugin config for dynamic-cursors
-- Only applies if the dynamic-cursors plugin is currently loaded

local function apply_dynamic_cursors_config()
    local loaded_plugins = hl.get_loaded_plugins() or {}
    local is_loaded = false
    for _, p in ipairs(loaded_plugins) do
        if p.name == "dynamic-cursors" then
            is_loaded = true
            break
        end
    end

    if is_loaded then
        hl.config({
            plugin = {
                ["dynamic-cursors"] = {
                    enabled = true,
                    mode = "stretch",
                    threshold = 2,
                    rotate = {
                        length = 20,
                        offset = 0.0,
                    },
                    tilt = {
                        limit = 5000,
                        ["function"] = "negative_quadratic",
                    },
                    stretch = {
                        limit = 3000,
                        ["function"] = "quadratic",
                    },
                    shake = {
                        enabled = true,
                        nearest = true,
                        threshold = 5.0,
                        base = 4.0,
                        speed = 4.0,
                        influence = 1.0,
                        limit = 5,
                        timeout = 1000,
                        effects = 0,
                        ipc = false,
                    },
                    hyprcursor = {
                        nearest = true,
                        enabled = true,
                        resolution = -1,
                        fallback = "clientside",
                    },
                },
            },
        })
    end
end

apply_dynamic_cursors_config()
hl.on("config.reloaded", apply_dynamic_cursors_config)
