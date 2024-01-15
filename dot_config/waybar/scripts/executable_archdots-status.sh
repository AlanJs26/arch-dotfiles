#!/bin/bash

source ~/.env.sh

if [ $(pgrep chezmoi) ]; then
    printf "󰑓 "
    exit
fi

count ()
{
	cat < /dev/stdin|grep -c -v '^\\s*$'
}

chezmoi git add . 2> /dev/null

dots_pending=$(archdots list dots --pending|count)

apps_unmanaged=$(archdots list apps --unmanaged|rg -vU '^(WARNING|\[|#|\n)'|count)
apps_pending=$(archdots list apps --pending|rg -N .|count)

[ $dots_pending -ne 0 ]&&printf "󰈙 $dots_pending "


if [ $apps_unmanaged -ne 0 ] || [ $apps_pending -ne 0 ]; then
	printf "󰏗 "
	[ $apps_pending -ne 0 ]&& printf "$apps_pending󰁅 "
	[ $apps_unmanaged -ne 0 ]&& printf "$apps_unmanaged󰁝"
fi
