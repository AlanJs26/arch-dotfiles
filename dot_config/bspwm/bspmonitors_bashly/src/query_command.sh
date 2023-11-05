
if [ -z "${args[--monitor]}" ] && [ -z "${args[--layout]}" ]; then
    bspmonitors query --help
    exit
fi

if [ -n "${args[--monitor]}" ]; then
    found="$(jq -r '.monitor_setup|map(.alias).[]' $BSPSETTINGS|grep "${args[--monitor]}"|tail -n1)"
    jq -r ".monitor_setup|map(select(.alias == \"$found\"))[0].name" $BSPSETTINGS 
elif [ -n "${args[--layout]}" ]; then
    found="$(jq -r '.monitor_layouts|map(.name).[]' $BSPSETTINGS|grep "${args[--layout]}"|tail -n1)"
    jq -r ".monitor_layouts|map(select(.name == \"$found\"))" $BSPSETTINGS 
fi
