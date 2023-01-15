#!/usr/bin/env bash

PATH=~/Pictures/Scripts/:"$PATH"

function main() {
  set -e

  card="X-T5 #1"
  date=$( date +'%Y-%m-%d' )
  year=$( date +'%Y' )
  new_photos=~/Pictures/Photographs/"$year/$date"
  newly_imported_photos=~/Pictures/Photographs/Importing

  set -x

  update-metadata "$newly_imported_photos"
  move-and-rename "$newly_imported_photos" "$new_photos"
  open-in-bridge "$new_photos"
  erase-photos-from-card "$card"
  unmount-card "$card"
}

main
