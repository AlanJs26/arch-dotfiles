
if [ -z "${args[--monitor]}" ] && [ -z "${args[--layout]}" ]; then
    $BSPDIR/bspmonitors_bashly/bspmonitors query --help
    exit
fi

if [ -n "${args[--monitor]}" ]; then
    found="$(jq -r '.monitor_setup|map(.alias).[]' $BSPDIR/settings.json|grep "${args[--monitor]}"|tail -n1)"
    jq -r ".monitor_setup|map(select(.alias == \"$found\"))[0].name" $BSPDIR/settings.json 
elif [ -n "${args[--layout]}" ]; then
    found="$(jq -r '.monitor_layouts|map(.name).[]' $BSPDIR/settings.json|grep "${args[--layout]}"|tail -n1)"
    jq -r ".monitor_layouts|map(select(.name == \"$found\"))" $BSPDIR/settings.json 
fi
