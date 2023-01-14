#!/bin/bash

PATH=~/Pictures/Scripts/:"$PATH"

function main() {
  set -e

  card="X-T5 #1"
  date=$( date +'%Y-%m-%d' )
  new_photos=~/Pictures/X-T5/"$date"

  set -x

  move-newly-imported-photos-to "$new_photos"
  open-in-bridge "$new_photos"
  erase-photos-from-card "$card"
  unmount-card "$card"
}

main
