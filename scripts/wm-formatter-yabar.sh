#!/usr/bin/env bash

yabar_fg() {
  color="$1"
  shift
  # "!Y BG 0xFFFF0000 fg0xFF00ff00 U0xFFFAC739 Y!"
  # echo -n "%{F${color}}$*  %{F-}"
  # echo -n "!Y FG 0x${color}FF $* Y!"
  echo -n "<span foreground='$color'>$*</span> "
}

format_empty()    { yabar_fg "#${EMPTY_COLOR:-33333300}"    "$1" ;}
format_visible()  { yabar_fg "#${VISIBLE_COLOR:-99999900}"  "$1" ;}
format_occupied() { yabar_fg "#${OCCUPIED_COLOR:-66666600}" "$1" ;}
format_urgent()   { yabar_fg "#${URGENT_COLOR:-ff000000}"   "$1" ;}
format_focused()  { yabar_fg "#${FOCUSED_COLOR:-ffffff00}"  "$1" ;}

path="$(dirname $0)"
source $path/wm-formatter-base.sh
