local mainMod = "SUPER"

hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("pgrep wl-kbptr || wl-kbptr -o modes=tile -c ~/.config/wl_kbptr/config.toml"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("pgrep wl-kbptr || wl-kbptr -o modes=tile,split,click -c ~/.config/wl_kbptr/config.toml"))
