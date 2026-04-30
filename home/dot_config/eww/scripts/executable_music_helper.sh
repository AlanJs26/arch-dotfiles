#!/usr/bin/env bash

STATUS=$(playerctl status 2>&1)
MUSIC_DIR="$HOME/Music"
YTMUSIC_DIR="$HOME/.config/YouTube Music"
DEFAULT_ICON="󰑗"
## Get status
get_status() {
	if [[ $STATUS == *"Playing"* ]]; then
		echo "󰏤"
	else
		echo "󰐊"
	fi
}


get_single() {
	if [[ $STATUS == *"single: on"* ]]; then
		echo "true"
    DEFAULT_ICON="󰑘"
	else
		echo "false"
	fi
}


get_random() {
	if [[ $STATUS == *"random: on"* ]]; then
    DEFAULT_ICON="󰑖"
		echo "true"
	else
		echo "false"
	fi
}

get_repeat() {
	if [[ $STATUS == *"repeat: on"* ]]; then
    MODE='PLAYLIST'
		echo "true"
	else
		echo "false"
	fi
}
## Get song
get_song() {
	playerctl metadata --format "{{ title }}"
}

## Get artist
get_artist() {
	playerctl metadata --format "{{ artist }}"
	artist=`mpc -f %artist% current`
	if [[ -z "$artist" ]]; then
		echo " "
	else
    count=$(echo -n "$artist" | wc -c)
    if [ "$count" -le 35 ]; then
		  echo by $artist
	  else 
		  echo by ${artist:0:35}...
	  fi
	fi	
}

to_time() {
	minutes=$(echo "$1/60"|bc)
	seconds=$(echo "$1%60"|bc)
	echo "$minutes:$seconds"
}

get_ctime() {
	current=$(playerctl position)
	echo "$current/1"|bc
	# ctime=`mpc status | grep "#" | awk '{print $3}' | sed 's|/.*||g'`
	# if [[ -z "$ctime" ]]; then
	# 	echo " "
	# else
	# 	echo "$ctime"
	# fi	
}
get_ttime() {
	duration=$(playerctl metadata --format "{{mpris:length}}")
	echo "$(($duration/1000000))"
	# ttime=`mpc -f %time% current`
	# if [[ -z "$ttime" ]]; then
	# 	echo " "
	# else
	# 	echo "$ttime"
	# fi	
}


## Get time
get_time() {
	echo "($(get_ctime)/$(get_ttime))*100"|bc -l
	# time=`mpc status | grep "%)" | awk '{print $4}' | tr -d '(%)'`
	# if [[ -z "$time" ]]; then
	# 	echo "0"
	# else
	# 	echo "$time"
	# fi	
}

COVER="/tmp/cover.png"
CROP_BORDER=100
COVER_SIZE=297
ffmpeg_cover() {
    ffmpeg -loglevel 0 -y -i "$1" -vf "crop=min(in_w-$CROP_BORDER\,in_h-$CROP_BORDER):out_w,scale=-2:$COVER_SIZE" "$COVER"
    #ffmpeg -hide_banner -loglevel 0 -y -i "$1" -vf "crop='if(gt(ih,iw),iw,ih)':'if(gt(iw,ih),ih,iw)'" "$COVER" 
}


## Get cover
fetch_cover() {
	ART_FROM_SPOTIFY="$(playerctl -p %any,spotify metadata mpris:artUrl 2>/dev/null | sed -e 's/open.spotify.com/i.scdn.co/g')"
	ART_FROM_BROWSER="$(playerctl -p %any,mpd,firefox,chromium,brave metadata mpris:artUrl 2>/dev/null | sed -e 's/file:\/\///g')"

	if [[ $(playerctl -p spotify,%any,firefox,chromium,brave,mpd metadata mpris:artUrl 2>/dev/null) ]]; then
		ffmpeg_cover "$ART_FROM_SPOTIFY" 
	elif [[ -n "$ART_FROM_BROWSER" ]]; then
		ffmpeg_cover "$ART_FROM_BROWSER" 
		echo "$ART_FROM_SPOTIFY"
	elif [[ -n "$(pgrep youtube-music)" ]]; then
		ytid=$(jq .url "$YTMUSIC_DIR/config.json"|rg "watch.v=(.+?)&|\$" -or '$1')
		imgurl="https://img.youtube.com/vi/$ytid/hqdefault.jpg"
		ffmpeg_cover "$imgurl"
	else
		tail -n1 /tmp/music
	fi
	echo "$COVER"

}

cover_daemon_python() {
	eww_scripts="$HOME/.config/eww/scripts"
	$eww_scripts/cover_daemon_py/.venv/bin/python $eww_scripts/cover_daemon_py/main.py
}

cover_daemon_ytmusic() {
	echo "Started YoutubeMusic cover daemon!"
	fetch_cover | tee /tmp/music
	while true; do
		if [[ $(pgrep youtube-music) ]]; then
			inotifywait -q -e modify "$YTMUSIC_DIR/config.json"
		else
			sleep 1
			continue
		fi
		fetch_cover | tee /tmp/music
	done
}

cover_daemon() {
	pgrep -f cover_daemon_py|xargs kill
	echo /tmp/cover.png > /tmp/music
	cover_daemon_python&
	cover_daemon_ytmusic
}

cover_listen() {
	tail -n1 /tmp/music
	while true; do
		inotifywait -q -e modify "/tmp/music"
		tail -n1 /tmp/music
	done
}

## Execute accordingly
if [[ "$1" == "--parse_cover" ]]; then
	ffmpeg_cover $2
elif [[ "$1" == "--song" ]]; then
	get_song
elif [[ "$1" == "--artist" ]]; then
	get_artist
elif [[ "$1" == "--status" ]]; then
	get_status
elif [[ "$1" == "--time" ]]; then
	get_time
elif [[ "$1" == "--ctime" ]]; then
	to_time $(get_ctime)
elif [[ "$1" == "--ttime" ]]; then
	to_time $(get_ttime)
elif [[ "$1" == "--cover_daemon" ]]; then
	cover_daemon
elif [[ "$1" == "--cover" ]]; then
	tail -n1 /tmp/music
elif [[ "$1" == "--cover_listen" ]]; then
	cover_listen
elif [[ "$1" == "--toggle" ]]; then
	playerctl play-pause
elif [[ "$1" == "--random" ]]; then
	mpc random
elif [[ "$1" == "--shuffle" ]]; then
	mpc shuffle
elif [[ "$1" == "--single" ]]; then
	mpc single
elif [[ "$1" == "--repeat" ]]; then
	mpc repeat
elif [[ "$1" == "--getrandom" ]]; then
	get_random
elif [[ "$1" == "--getrepeat" ]]; then
	get_repeat
elif [[ "$1" == "--getsingle" ]]; then
	get_single
elif [[ "$1" == "--next" ]]; then
	{ playerctl next 2>&1; fetch_cover; }
elif [[ "$1" == "--prev" ]]; then
	{ playerctl previous 2>&1; fetch_cover; }
fi
