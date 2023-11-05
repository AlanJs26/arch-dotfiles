

if [ -z "${args[--list_monitors]}" ] && [ -z "${args[--list_layouts]}" ]; then
    bspmonitors --help
    exit
fi

if [ "${args[--list_monitors]}" = "1" ]; then
    jq -r '.monitor_setup|map(.alias).[]' $BSPSETTINGS
elif [ "${args[--list_layouts]}" = "1" ]; then
    jq -r '.monitor_layouts|map(.name).[]' $BSPSETTINGS
fi
