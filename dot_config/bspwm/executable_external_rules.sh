#!/bin/sh

wid=$1
class=$2
instance=$3
consequences=$4
id=${1?}

spotify() { state=floating; }

get_win_name() {
    xprop -id $1|rg "^WM_NAME.+\"(.+?)\"" -r '$1'
}

if [ "$class" = "__main__.py" ] && grep -q "TexText" <<< "$(get_win_name $1)"; then
    state=floating; 
fi

case $instance.$class in
    .)
        case $(exec ps -p "$(exec xdo pid "$id")" -o comm= 2>/dev/null) in
            spotify) spotify ;;
            *) exit 0 ;;
        esac
    ;;
esac

printf '%s ' \
    ${border:+"border=$border"} \
    ${center:+"center=$center"} \
    ${desktop:+"desktop=$desktop"} \
    ${focus:+"focus=$focus"} \
    ${follow:+"follow=$follow"} \
    ${hidden:+"hidden=$hidden"} \
    ${layer:+"layer=$layer"} \
    ${locked:+"locked=$locked"} \
    ${manage:+"manage=$manage"} \
    ${marked:+"marked=$marked"} \
    ${monitor:+"monitor=$monitor"} \
    ${node:+"node=$node"} \
    ${private:+"private=$private"} \
    ${rectangle:+"rectangle=$rectangle"} \
    ${split_dir:+"split_dir=$split_dir"} \
    ${split_ratio:+"split_ratio=$split_ratio"} \
    ${state:+"state=$state"} \
    ${sticky:+"sticky=$sticky"} \
    ${urgent:+"urgent=$urgent"}

