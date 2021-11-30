#!/usr/bin/env bash

# yambar yml: https://github.com/sagotsky/.dotfiles/blob/master/config/yambar/config.yml#L235-L320

format_ws() {
  name="$1"
  state="$2"
  id="$3"

  echo "workspace-${id}-state|string|${state}"
  echo "workspace-${id}-name|string|${name}"
}

path="$(dirname $0)"
source $path/wm-formatter-base.sh
