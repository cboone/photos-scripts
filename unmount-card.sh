#!/bin/bash

function main() {
  diskutil unmount /Volumes/"$1"
}

main "$1"
