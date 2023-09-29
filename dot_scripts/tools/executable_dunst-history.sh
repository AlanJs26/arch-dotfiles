#a=$(cat /home/alan/.dunstHistory)
#if [[ $a == "sim" ]]; then 
    #echo "que?"
    #for i in $(seq 1 20); do
        #/usr/bin/dunstctl history-pop;
    #done
    #echo "nao" > /home/alan/.dunstHistory  
#else
    #/usr/bin/dunstctl close-all;
    #echo "$a"
    #echo "sim" > /home/alan/.dunstHistory 
#fi

for i in $(seq 1 3); do
    dunstctl history-pop;
done
