function show_usage(){
    echo -e "Usage: \n       duolingo.sh --user USERNAME [streak|extended_streak|xp|userid|language|picture]"
    exit
}

case "$1" in
  ""|"-h"|"--help")
    show_usage
    ;;
esac


if [[ "$1" = "--user" ]] && [[ -n "$2" ]] && [[ -n "$3" ]]; then
  username="$2"
else
    show_usage
fi

data="$(curl "https://www.duolingo.com/2017-06-30/users?username=${username}&fields=id,name,streak,streakData%7BcurrentStreak,previousStreak%7D,totalXp,username%7D" \
             -H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36' \
             --compressed --silent)"

case "$3" in

  "streak") 
    echo "$data"|jq -r '.users[0].streak'
    ;;
  "extended_streak") 
    endStreakDate="$(echo "$data"|jq -r '.users[0].streakData.currentStreak.endDate')"
    if [[ "$(date +'%Y-%m-%d')" = "$endStreakDate" ]]; then
      echo yes
    else
      echo no
    fi
    ;;
  "xp") 
    echo "$data"|jq -r '.users[0].totalXp'
    ;;
  "userid")
    echo "$data"|jq -r '.users[0].id'
    ;;
  "language")
    echo "$data"|jq -r '.users[0].learningLanguage'
    ;;
  "picture")
    echo "$data"|jq -r '.users[0].picture'
    ;;
  *) show_usage;;
esac
