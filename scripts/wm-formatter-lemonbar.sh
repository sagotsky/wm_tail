#!/usr/bin/env bash

lemonbar_fg() {
  color="$1"
  shift

  # Default label: workspace name
  # Can override all with WS_ICON
  # Can override specific with WS_ICON_N (for N = 0-9)

  icon_var="WS_ICON_$*"
  icon="${!icon_var:-${WS_ICON:-$@}}"
  printf "%%{F%s}%s %%{F-}" "$color" "$icon"
}

format_empty()    { lemonbar_fg "#${EMPTY_COLOR:-333333}"    "$1" ;}
format_visible()  { lemonbar_fg "#${VISIBLE_COLOR:-aaaaaa}"  "$1" ;}
format_occupied() { lemonbar_fg "#${OCCUPIED_COLOR:-666666}" "$1" ;}
format_urgent()   { lemonbar_fg "#${URGENT_COLOR:-ff0000}"   "$1" ;}
format_focused()  { lemonbar_fg "#${FOCUSED_COLOR:-ffffff}"  "$1" ;}

path="$(dirname $0)"
source $path/wm-formatter-base.sh
