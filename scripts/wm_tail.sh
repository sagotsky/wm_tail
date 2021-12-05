#!/usr/bin/env bash

# Helper script for launching without a pipe.  Yambar's script module doesn't take a pipe and needs a wrapper.
path="$(dirname $0)"

if [ -f "$*" ] ; then
  formatter="$*"
elif [ -f "$path/$*" ] ; then
  formatter="$path/$*"
else
  echo "Please specify the absolute path of a formatter script or the name of a script in the '$path' directory"
  exit 1
fi

"$path/../wm_tail.rb" | $formatter
