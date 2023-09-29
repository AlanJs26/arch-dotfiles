pacdef package sync 2> /dev/null

unmanaged=$(echo "$(pacdef package unmanaged 2> /dev/null)"|rg -vU '^(WARNING|\[|#|\n)'|wc -l)

if [ $unmanaged -gt 0 ]; then
	echo -e "you have $unmanaged unmanaged packages\nRun 'archdots list --unmanaged' to view them or 'archdots review' to decide what to do with each one"
fi
