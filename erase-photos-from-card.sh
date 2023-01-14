#!/bin/bash

function main() {
  set -e

  rm -fr /Volumes/"$1"/*
}

main "$1"
