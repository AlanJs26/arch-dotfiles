
find_difference() {
    local list1=("$@")
    local list2=("${list1[@]}")

    for item in "${list1[@]}"; do
        for elem in "${list2[@]}"; do
            if [[ "$item" == "$elem" ]]; then
                list1=("${list1[@]/$item}")
                break
            fi
        done
    done

    echo "${list1[@]}"
}
chezmoi git add . 2> /dev/null

dots_pending=$(archdots list dots --pending|wc -l)

apps_unmanaged=$(archdots list apps --unmanaged|rg -vU '^(WARNING|\[|#|\n)'|wc -l)
apps_pending=$(archdots list apps --pending|rg -N .|wc -l)

[ $dots_pending -ne 0 ]&&printf "󰈙 $dots_pending "


if [ $apps_unmanaged -ne 0 ] || [ $apps_pending -ne 0 ]; then
	printf "󰏗 "
	[ $apps_pending -ne 0 ]&& printf "$apps_pending󰁅 "
	[ $apps_unmanaged -ne 0 ]&& printf "$apps_unmanaged󰁝"
fi
