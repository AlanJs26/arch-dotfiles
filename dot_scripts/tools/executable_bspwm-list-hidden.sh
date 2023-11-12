#!/usr/bin/sh

# get_win_name() {
#     xwininfo -id "$1"|head -n2|rg "\"(.+)\"" -r '$1' -o
# }
get_win_class() {
    xprop -id $1|rg "^WM_CLASS.+\"(.+?)\"" -r '$1'
}
get_win_name() {
    xprop -id $1|rg "^WM_NAME.+\"(.+?)\"" -r '$1'
}

count=0
if [ $(bspc query -N -n .leaf.hidden|wc -l) -gt 0 ]; then
    parsed=()
    nodes=($(bspc query -N -n .leaf.hidden))

    for value in "${nodes[@]}"; do
        node_name="$(get_win_name $value)"
        node_class="$(get_win_class $value)"

        if [ -f /tmp/swallowids ] && [ -n "$(rg "$value" /tmp/swallowids)" ]; then
            continue
        fi

        icon=""
        
        case "$node_class" in
            kitty|__float__|__float_center__)
                icon=""
                ;;
            Qalculate-gtk)
                icon=""
                ;;
            Spotify|"YouTube Music")
                icon=""
                ;;
            com-azefsw-audioconnect-desktop-app-MainKt)
                icon=""
                ;;
            __pluto__)
                icon=""
                ;;
            __matlab__)
                icon="󰘨"
                ;;
            __jupyter__)
                icon=""
                ;;
            sioyek)
                icon=""
                ;;
        esac

        case "$icon-$node_name" in
            -floatkittynvim)
                icon="󰅩"
                ;;
        esac


        if [ -n "$icon" ]; then
            parsed=(${parsed[@]} "%{A1:bspc node $value --flag hidden=off:}%{F#c0caf5}$icon %{F-}%{A}")
        else
            let "count+=1"
        fi

    done

    if [ $count -gt 0 ]; then
        echo "  $count ${parsed[@]}"
    else
        echo "${parsed[@]}"
    fi
else
    echo "  0"
fi


# echo "nvim  %{F#e0af68} Youtube Music %{F-}  Firefox"
