#!/usr/bin/env bash

polybar_fg() {
  color="$1"
  shift

  echo -n "%{F${color}}$*  %{F-}"
}

format_empty()    { polybar_fg "#${EMPTY_COLOR:-333333}"    "$1" ;}
format_visible()  { polybar_fg "#${VISIBLE_COLOR:-aaaaaa}"  "$1" ;}
format_occupied() { polybar_fg "#${OCCUPIED_COLOR:-666666}" "$1" ;}
format_urgent()   { polybar_fg "#${URGENT_COLOR:-ff0000}"   "$1" ;}
format_focused()  { polybar_fg "#${FOCUSED_COLOR:-ffffff}"  "$1" ;}

path="$(dirname $0)"
source $path/wm-formatter-base.sh
