#!/bin/sh

# Convert to Indexed version 1.0
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
    #echo
    #echo "Removing semi-transparency ..."

    # Step 1: Remove semi-transparency from pixels.
    # Arguments:
    convert -verbose "${IMG}" -define png:color-type=6 -channel Alpha -threshold 20% "${IMG}"


    echo
    echo "Converting \"${IMG}\" to indexed color ..."

    # Step 2: Convert image to indexed color.
    # Arguments:
    #   -colors 255: Make 8-bit palette
    #   -type PaletteMatte: ???
    #convert -verbose -define png:color-type=6 -colorspace sRGB "${IMG}" -depth 4 -define png:color-type=3 -colors 255 -type Palette "${IMG}"


    # Step 2 alt: Convert image to indexed color with pngquant.
    pngquant -v --force --nofs --speed 1 --quality 100-100 -o "${IMG}" 255 "${IMG}"
done


echo
echo "Done!"
