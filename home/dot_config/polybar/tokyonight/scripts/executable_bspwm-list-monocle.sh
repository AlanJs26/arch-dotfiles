#!/usr/bin/sh

# get_win_name() {
#     xwininfo -id "$1"|head -n2|grep "\"(.+)\"" -E -o
# }
#
#

if [ -n "$1" ]; then
    target_monitorid="$($HOME/.config/polybar/tokyonight/scripts/polybar-monitor-by-pid.sh/polybar-monitor-by-pid.sh $1)"
else
    target_monitorid="$(bspc query -M -m)" 
fi


if [ "$(bspc query -T -d $(bspc query -D -m $target_monitorid -d .active)|jq .userLayout -r)" = "monocle" ]; then
    if [ $(bspc query -N -m $target_monitorid -n .leaf.\!floating|wc -l) -gt 1 ]; then
        parsed=()
        focused_node="$(bspc query -N -n .focused)"
        # focused_name="$(get_win_name $focused_node)"

        nodes=($(bspc query -N -m $target_monitorid -d .active -n .leaf.\!floating.\!hidden))

        for value in "${nodes[@]}"; do
            node_name="$(bspc query -T -n "$value"|jq .client.className -r)"

            if [ "$value" = "$focused_node" ]; then
                parsed=(${parsed[@]} "%{F#e0af68}$node_name%{F-}")
            else
                parsed=(${parsed[@]} "%{A1:bspc node $value -f:}$node_name%{A}")
            fi
        done


      # bspc node -f {next,prev}.local.\!hidden.window
        echo "  %{A5:bspc node -f prev.local.!hidden.window:}%{A4:bspc node -f next.local.!hidden.window:}$(echo "${parsed[@]}"|sed 's/ /   /g')%{A}%{A}"
    else
        echo "  %{F#7aa2fa}monocle%{F}"
    fi
else
    echo ""
fi

# echo "nvim  %{F#e0af68} Youtube Music %{F-}  Firefox"
