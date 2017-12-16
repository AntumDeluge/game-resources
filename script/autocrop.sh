#!/bin/bash

FILES=$@

for PNG in ${FILES}; do
  SOURCE="${PNG}"

  echo "Cropping image \"${SOURCE}\" ..."
  convert -verbose "${SOURCE}" -define png:format=png32 -trim "${SOURCE}"
done
