pacdef package sync

unmanaged=$(echo "$(pacdef package unmanaged)"|rg -vU '^(WARNING|\[|#|\n)'|wc -l)

if [ $unmanaged -gt 0 ]; then
	echo "you have $unmanaged unmanaged packages\nRun 'archdots list --unmanaged' to view them or 'archdots review' to decide what to do with each one"
fi
