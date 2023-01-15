#!/usr/bin/env bash

function main() {
  from_directory="$1"
  to_directory="$2"

  set -ex

  exiftool \
    -d "$to_directory"/%Y/%Y-%m-%d/%Y%m%d-%%f.%%e \
    "-filename<CreateDate" \
    "$from_directory"
}

main "$1" "$2"
