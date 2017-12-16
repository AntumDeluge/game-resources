#!/bin/bash

FILES=$@

for PNG in ${FILES}; do
  SOURCE="${PNG}"

  echo "Converting ${SOURCE} to sRGB ..."
  convert "${SOURCE}" -define png:format=png32 "${SOURCE}"
done
