# echo "# this file is located in 'src/layout_command.sh'"
# echo "# code for 'bspmonitors layout' goes here"
# echo "# you can edit it freely and regenerate (it will not be overwritten)"
# inspect_args

layout="$(jq -r ".monitor_layouts|map(select(.name == \"${args[name]}\"))[0]" $BSPSETTINGS)"
monitor_setup="$(jq -r ".monitor_setup" $BSPSETTINGS)"
n_layout=$(echo "$layout"|jq -r '.layout|length')

json ()
{
    out="$(echo "$1"|jq -r "$2" 2> /dev/null)"
    if [ "$out" != "null" ]; then
        echo "$out"
    fi
}

output="xrandr "
output_bspc=""
for i in $(seq 0 $((n_layout-1))); do
    monitor_alias="$(json "$layout" ".layout[$i].monitor_alias")"
    primary="$(json "$layout" ".layout[$i].primary")"
    enabled="$(json "$layout" ".layout[$i].enabled")"
    x="$(json "$layout" ".layout[$i].x")"
    y="$(json "$layout" ".layout[$i].y")"
    bspwm_desktops="$(json "$layout" ".layout[$i].bspwm_desktops")"
    mirror="$(json "$layout" ".layout[$i].mirror")"
    width_override="$(json "$layout" ".layout[$i].width")"
    height_override="$(json "$layout" ".layout[$i].height")"

    monitor_config="$(json "$monitor_setup" "map(select(.alias == \"$monitor_alias\"))[0]")"

    width="$(json "$monitor_config" ".width")"
    height="$(json "$monitor_config" ".height")"
    monitor="$(json "$monitor_config" ".name")"

    output="$output --output $monitor"
    if [ "$enabled" = "true" ]; then

        [ "$primary" = "true" ] && output="$output --primary"

        if [ -n "$width_override" ] && [ -n "$height_override" ]; then
            output="$output --mode ${width_override}x${height_override}"
        elif [ -n "$width" ] && [ -n "$height" ]; then
            output="$output --mode ${width}x${height}"
        fi

        [ -n "$x" ] && [ -n "$y" ] && output="$output --pos ${x}x${y}"

        if [ -n "$mirror" ]; then
            mirror_name="$(json "$monitor_setup" "map(select(.alias == \"$mirror\"))[0].name")"
            # mirror_name="$(echo $monitor_setup|jq -r "map(select(.alias == \"$mirror\"))[0].name")"
            output="$output --same-as $mirror_name"
        fi

        [ -n "$bspwm_desktops" ] && output_bspc="$output_bspc; bspc monitor $monitor -d $bspwm_desktops"

    else
        output="$output --off"
    fi
done

eval "$output"
eval "$(echo $output_bspc|sed 's/;//')"



