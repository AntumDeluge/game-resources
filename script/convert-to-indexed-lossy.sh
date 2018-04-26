#!/bin/sh

# Convert to Indexed version (lossy) 1.0
#
# Script for converting an image to indexed color.
# Supports formats supported by ImageMagick.
#
# This script is licensed under Creative Commons Zero (CC0). This is
# essentially public domain.
#
# Dependencies:
#  - Requires pngquant
#
# Please report any bugs to: antumdeluge@gmail.com


# Source file
SOURCE=$@

# Directory of source image
SDIR=$(dirname "${SOURCE}")

# Source filename
SNAME=$(basename "${SOURCE}")


echo
echo "Directory: ${SDIR}"


for IMG in ${SOURCE}; do
    echo
    echo "Converting \"${IMG}\" to indexed color ..."


    # Arguments:
    #  - v: Verbose
    #  - f: Force overwrite source image
    #  - nofs:
    #  - speed 1: Prioritze quality over speed
    #  - quality 80-100: Allow quality loss of up to 20% (lossy)
    pngquant -v -f --nofs --speed 1 --quality 80-100 -o "${IMG}" 256 "${IMG}"
done


echo
echo "Done!"
