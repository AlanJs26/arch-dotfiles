#!/usr/bin/env zsh

to_ignore=(
  "bspscripts"
  "Unified Remote"
  "in Folder"
)

function _set_vars() {
  typeset -gx DUNST_CACHE_DIR="$HOME/.cache/dunst"
  typeset -gx DUNST_LOG="$DUNST_CACHE_DIR/notifications.txt"
  typeset -gx DEFAULT_QUOTE="To fake it is to stand guard over emptiness. ── Arthur Herzog"
  typeset -gx DUNST_QUOTES="$DUNST_CACHE_DIR/quotes.txt"
}

function _unset_vars() {
  unset DUNST_CACHE_DIR
  unset DUNST_LOG
  unset DUNST_QUOTES
  unset DEFAULT_QUOTE
}
_set_vars

mkdir "$DUNST_CACHE_DIR" 2>/dev/null
touch "$DUNST_LOG" 2>/dev/null

function create_cache() {
  local urgency
  case "$DUNST_URGENCY" in
    "LOW"|"NORMAL"|"CRITICAL") urgency="$DUNST_URGENCY";;
    *) urgency="OTHER";;
  esac

  local summary
  local body
  [ "$DUNST_SUMMARY" = "" ] && summary="Summary unavailable." || summary="$(print "$DUNST_SUMMARY"|$HOME/.config/eww/scripts/parse_html.sh)"
  [ "$DUNST_BODY" = "" ] && body="Body unavailable." || body="$(print "$DUNST_BODY" | $HOME/.config/eww/scripts/parse_html.sh)"

  local glyph
  case "$urgency" in
    "LOW") glyph="󰋽";;
    "NORMAL")
      glyph="󱝁"

      local has_match="0"

      for item in "${to_ignore[@]}"; do
        if [[ $(echo "$DUNST_APP_NAME $DUNST_SUMMARY $DUNST_BODY"|grep "$item") ]]; then
          has_match="1"
          break
        fi
      done

      if [ "$has_match" = "0" ]; then
        add_pending
      fi

      ;;
    "CRITICAL") glyph="󰋽";;
    *) glyph="󰓏";;
  esac


  if [ -n "$(echo $DUNST_SUMMARY|rg "Mudae")" ]; then
    return
  fi
  if [ -n "$(echo $DUNST_BODY|rg "^\\\$wa")" ]; then
    return
  fi
  if [ -n "$(echo $DUNST_BODY|rg "Sincronizando mensagens em")" ]; then
    return
  fi

  case "$DUNST_APP_NAME" in
    "Spotify" | "mpd") return;; # don't show music notifications
    "sxhkd") glyph="󰌌";;
    "flameshot") glyph="󰢨";;
    "firefox") glyph="󰈹";;
    "Vivaldi") glyph="󰖟";;
    "discord") glyph="󰙯";;
    "bspwm") glyph="";;
    # "picom") glyph="󰽮";;
    # "changebrightness") glyph="󰃠";;
    # "nightmode") glyph="󰌵";;
    # "microphone") glyph="󰍰";;
    # "changevolume") glyph="󰕾";;
  esac

  if [ -n "$(echo $DUNST_BODY|rg "web\.whatsapp")" ]; then
    glyph=""
  fi



  # pipe stdout -> pipe cat stdin (cat conCATs multiple files and sends to stdout) -> absorb stdout from cat
  # concat: "one" + "two" + "three" -> notice how the order matters i.e. "one" will be prepended
  # print '(card :width 400 :class "control-center-card control-center-card-'$urgency' control-center-card-'$DUNST_APP_NAME'" :glyph_class "control-center-'$urgency' control-center-'$DUNST_APP_NAME'" :SL "'$DUNST_ID'" :L "dunstctl history-pop '$DUNST_ID'" :body `'$body'` :summary `'$summary'` :glyph "'$glyph'")' \
  # print $body\
  print '(card :width 400 :class "control-center-card control-center-card-'$urgency' control-center-card-'$DUNST_APP_NAME'" :glyph_class "control-center-'$urgency' control-center-'$DUNST_APP_NAME'" :SL "'$DUNST_ID'" :body `'$body'` :summary `'$summary'` :glyph "'$glyph'" :date "'$(date +"%d/%m/%y %H:%M %p")'")' \
    | cat - "$DUNST_LOG" \
    | sponge "$DUNST_LOG"
}

function compile_caches() { tr '\n' ' ' < "$DUNST_LOG" }

function make_literal() {
  local caches="$(compile_caches)"
  [[ "$caches" == "" ]] \
    && print '(box :class "control-center-empty-box" :width 430 :height 660 :orientation "vertical" :space-evenly false (image :class "control-center-empty-banner" :valign "end" :vexpand true :path "assets/empty-notification.svg" :image-width 200 :image-height 200) (label :vexpand true :valign "start" :wrap true :class "control-center-empty-label" :text "No Notifications!"))' \
    || print "(scroll :width 430 :height 660 :vscroll true (box :hexpand true :orientation 'vertical' :class 'control-center-scroll-box' :spacing 15 :space-evenly false $caches))"
}

function clear_logs() {
  killall dunst 2>/dev/null
  dunst & disown
  print > "$DUNST_LOG"
}

function pop() { sed -i '1d' "$DUNST_LOG" }

function drop() { sed -i '$d' "$DUNST_LOG" }

function remove_line() { sed -i '/SL "'$1'"/d' "$DUNST_LOG" }

function critical_count() { 
  local crits=$(cat $DUNST_LOG | grep CRITICAL | wc -l)
  print $crits
}

function normal_count() { 
  local new_log=$(cat $DUNST_LOG | grep NORMAL)

  for item in "${to_ignore[@]}"; do
    local new_log=$(printf "%s" "$new_log" | grep -v "$item")
  done

  # 4/2.5
  # local count=$(printf "%s" "$new_log" | wc -l)
  local count=$(printf "%s" "$new_log" | sed -n '$=')
  
  if [ -z "$count" ]; then
    print 0
  else
    print $count
  fi
}

function subscribe() {
  make_literal
  local lines=$(cat $DUNST_LOG | wc -l)
  while sleep 0.1; do
    local new=$(cat $DUNST_LOG | wc -l)
    [[ $lines -ne $new ]] && lines=$new && print
  done | while read -r _ do; make_literal done
}

function add_pending () {
  if [[ -f /tmp/pending-notifications.txt ]]; then
    echo "$(($(cat /tmp/pending-notifications.txt)+1))" > /tmp/pending-notifications.txt
  else
    echo "1" > /tmp/pending-notifications.txt
  fi
}

function clear_pending () {
  echo "0" > /tmp/pending-notifications.txt
}

function drop_pending () {
  if [[ -f /tmp/pending-notifications.txt ]] && [[ "$(cat /tmp/pending-notifications.txt)" -gt 0 ]]; then
    echo "$(($(cat /tmp/pending-notifications.txt)-1))" > /tmp/pending-notifications.txt
  fi
}

function get_pending () {
  cat /tmp/pending-notifications.txt 2> /dev/null|| echo 0
}

case "$1" in
  "pop") pop; drop_pending;;
  "drop") drop; drop_pending;;
  "clear") clear_logs; clear_pending;;
  "subscribe") subscribe;;
  "rm_id") remove_line $2;;
  "crits") critical_count;;
  "normal") normal_count;;
  "add_pending") add_pending;;
  "drop_pending") drop_pending;;
  "clear_pending") clear_pending;;
  "pending") get_pending;;
  *) create_cache;;
esac

sed -i '/^$/d' "$DUNST_LOG"
_unset_vars

