

if [ -z "${args[--list_monitors]}" ] && [ -z "${args[--list_layouts]}" ]; then
    bspmonitors --help
    exit
fi

if [ "${args[--list_monitors]}" = "1" ]; then
    archdots settings '.monitor.setup|map(.alias).[]' -r
elif [ "${args[--list_layouts]}" = "1" ]; then
    archdots settings '.monitor.layouts|map(.name).[]' -r
fi
