

mode="$(echo 'monitors
scratchpad
ssh
colorpicker
shortcuts
applications
screensaver
window_class
zoxide'|rofi -dmenu -p 'rofi')"

case "$mode" in
    "--list")
        ;;
    monitors)
        $TOOLS/rofi-monitors.sh
        ;;
    scratchpad)
        $TOOLS/rofi-scratchpad-bspwm.sh
        ;;
    ssh)
        $TOOLS/rofi-ssh-aliases.sh
        ;;
    colorpicker)
        colorpicker-selection.sh
        ;;
    shortcuts)
        $HOME/.config/sxhkd/sxhkd-help
        ;;
    zoxide)
        $TOOLS/rofi-zoxide.sh
        ;;
    applications)
        rofi -show drun
        ;;
    screensaver)
        $TOOLS/rofi-lockscreen.sh
        ;;
    window_class)
        wmname=$(xprop|rg "^WM_CLASS.+\"(.+?)\"" -r '$1')
        printf "%s" "$wmname"|xclip -sel copy
        notify-send "WM_CLASS" "$wmname"
        ;;
    *)
        echo "unknown argument"
esac



