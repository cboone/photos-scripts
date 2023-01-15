#!/usr/bin/env bash

function main() {
  directory="$1"
  email="info@catamounthardware.com"
  lens_info='Venus Optics Laowa 10mm f/4'
  name='Christopher Boone'
  terms='No reproduction rights are granted without the express written permission of Christopher Boone. No other usage is expressed or implied.'
  url='https://catamounthardware.com'

  set -ex

  exiftool \
    -m \
    -overwrite_original_in_place \
    -P \
    -Artist="$name" \
    -Copyright="$name" \
    -Creator="$name" \
    -CreatorWorkEmail="$email" \
    -CreatorWorkURL="$url" \
    -Credit="$name" \
    -UsageTerms="$terms" \
    -WebStatement="$url" \
    "$directory"

  # shellcheck disable=2016
  exiftool \
    -m \
    -overwrite_original_in_place \
    -P \
    -if 'not defined $Lens or $Lens eq ""' \
    -FocalLength='10' \
    -FocalLengthIn35mmFormat='15' \
    -Lens="$lens_info" \
    -LensMake='Venus Optics Laowa' \
    -LensModel="$lens_info" \
    -LensType="$lens_info" \
    -MaxApertureValue='4' \
    "$directory"
}

main "$1"
