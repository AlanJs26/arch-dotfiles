
if [ -z "${args[--monitor]}" ] && [ -z "${args[--layout]}" ]; then
    bspmonitors query --help
    exit
fi

if [ -n "${args[--monitor]}" ]; then
    found="$(archdots settings '.monitor.setup|map(.alias).[]' -r|grep "^${args[--monitor]}$"|tail -n1)"
    archdots settings ".monitor.setup|map(select(.alias == \"$found\"))[0].name" -r 
elif [ -n "${args[--layout]}" ]; then
    found="$(archdots settings '.monitor.layouts|map(.name).[]' -r|grep "^${args[--layout]}$"|tail -n1)"
    archdots settings ".monitor.layouts|map(select(.name == \"$found\"))" -r
fi
