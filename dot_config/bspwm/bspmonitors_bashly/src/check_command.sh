# echo "# this file is located in 'src/check_command.sh'"
# echo "# code for 'bspmonitors check' goes here"
# echo "# you can edit it freely and regenerate (it will not be overwritten)"
# inspect_args

layout="${args[name]}"
layout_monitors="$(bspmonitors query --layout $layout|jq '.[0].layout[]|select(.enabled==true).monitor_alias' -r 2> /dev/null|xargs -i bspmonitors query --monitor {})"
all_monitors="$(xrandr -q|grep '\bconnected'|awk '{ print $1 }')"

for item in ${layout_monitors[@]}; do
    if [ -z "$(echo -n "$all_monitors"|grep "^$item$")" ]; then
        return
    fi
done

echo "available"
