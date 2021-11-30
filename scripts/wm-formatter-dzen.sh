#!/usr/bin/env bash

dzen_fg() {
  color="$1"
  shift

  printf "^fg(%s) %s ^fg()" "$color" "$@"
}

format_empty()    { dzen_fg "#${EMPTY_COLOR:-333333}"    "$1" ;}
format_visible()  { dzen_fg "#${VISIBLE_COLOR:-aaaaaa}"  "$1" ;}
format_occupied() { dzen_fg "#${OCCUPIED_COLOR:-666666}" "$1" ;}
format_urgent()   { dzen_fg "#${URGENT_COLOR:-ff0000}"   "$1" ;}
format_focused()  { dzen_fg "#${FOCUSED_COLOR:-ffffff}"  "$1" ;}

path="$(dirname $0)"
source $path/wm-formatter-base.sh
