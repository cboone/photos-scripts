#!/bin/bash

function main() {
  bridge_app_name="Adobe Bridge 2023"
  photos="$1"

  if pgrep "$bridge_app_name"; then
    osascript -e "quit app \"$bridge_app_name\""
    sleep 5
  fi

  open "/Applications/$bridge_app_name/$bridge_app_name.app" --args "$photos"
}

main "$1"
