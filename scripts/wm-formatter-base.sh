#!/usr/bin/env bash

defined() {
  [ "$(type -t $1)" == "function" ]
}

defined format_ws || format_ws() {
  name="$1"
  state="$2"
  _id="$3"

  format_method="format_${state}"
  $format_method "$name"
}

defined format_empty    || format_empty()    { printf "%s " "_";}
defined format_visible  || format_visible()  { printf "<%s> " "$1" ;}
defined format_occupied || format_occupied() { printf "%s " "$1" ;}
defined format_urgent   || format_urgent()   { printf "%s " "$1" ;}
defined format_focused  || format_focused()  { printf "%s " "$1" ;}

while read -r line ; do
  eval "$line"

  for ws in $WS_LIST  ; do
    name_var="WS_${ws}_NAME"
    state_var="WS_${ws}_STATE"

    # formatter="format_${!state_var}"
    # $formatter "${!name_var}" "${WS}"
    format_ws "${!name_var}" "${!state_var}" "${ws}"
    # TODO: decide if formatter should curry the state or not
  done
  echo
done
