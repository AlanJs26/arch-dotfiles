source ~/.env.sh

if [ -z "${args[app]}" ] && [ -z "${args[--list]}" ]; then
	archdots launch --help
	exit
fi

if [ -z "${args[app]}" ] || [ -n "${args[--list]}" ]; then
	archdots settings .apps
	exit
fi

app_name=$(archdots settings ".apps.${args[app]}" -r 2> /dev/null)

if [ "$app_name" != "null" ]; then
	$app_name
else
	echo "Could not find any app named \"${args[app]}\" in \"$BSPSETTINGS\""
fi


