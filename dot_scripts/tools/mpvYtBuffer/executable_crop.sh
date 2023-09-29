#ffmpeg -i "$(fd -e jpg|head -n 1)" -vf crop="'if(gt(ih,iw),iw,ih)':'if(gt(iw,ih),ih,iw)'" "$(fd -e jpg|head -n 1)"

mypath=$1
searchall=$(ls $mypath|grep --extended-regexp ".*(webp|jpg)$")

#mypath='/home/alan/Documentos/Codes/Python/Streaming/mpvYtBuffer/musics/'

if [[ -n $searchall ]]; then
        ls musics|grep --extended-regexp ".*(webp|jpg)$"|xargs -I GG -n1 bash -c "
        ffmpeg -hide_banner -loglevel error -i '${mypath//$/\\$}GG' -vf crop=\"'if(gt(ih,iw),iw,ih)':'if(gt(iw,ih),ih,iw)'\" \"${mypath//$/\\$}GG.jpg\" -y
        mv '${mypath//$/\\$}GG.jpg' '${mypath//$/\\$}GG'
        "
        fd . -e '.webp' -x sh -c 'mv "$0" "${0%.webp}.jpg"' {}

        /home/alan/miniconda3/bin/python "${2}addMetadata.py" "$mypath"
        fd -e jpg -x rm
        fd -e webp -x rm
        sleep 0.2
else
        echo 'não deu'
fi
