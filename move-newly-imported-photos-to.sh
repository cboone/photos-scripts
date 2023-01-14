#!/bin/bash

function main() {
  set -e

  new_directory="$1"

  mkdir -p "$new_directory"
  mv -f ~/Pictures/X-T5/"Importing from card"/*  "$new_directory"
}

main "$1"
