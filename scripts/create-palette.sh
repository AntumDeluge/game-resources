#!/bin/sh

# Create Palette version 1.0
#
# Script for creating a color palette file from an indexed image.
# Supports formats supported by ImageMagick.
#
# This script is licensed under Creative Commons Zero (CC0). This is
# essentially public domain.
#
# Dependencies:
#  - Requires ImageMagick (uses 'convert' executable)
#
# Please report any bugs to: antumdeluge@gmail.com


# Source file
SOURCE=$1

# Directory of source image
SDIR=$(dirname "${SOURCE}")

# Source filename
SNAME=$(basename "${SOURCE}")

# Output palette file name
PNAME=palette-"${SNAME}"

# Absolute path to output file
PTARGET="${SDIR}/${PNAME}"

echo
echo "Directory: ${SDIR}"
echo "Source file: ${SNAME}"
echo "Palette file: ${PNAME}"
echo "Target file: ${PTARGET}"

echo
echo "Creating palette ..."
echo


# STEP 1: Create the palette (includes transparency of source image)
# Arguments:
#   -colors 256: Make 8-bit palette
#   -unique-colors: Unknown
#   -scale 1000%: Creates 10x10 pixel tiles
#   -type PaletteAlpha: Ensures that output image has an alpha channel
#   -alpha activate: Ensures that output image has an alpha channel (unused)
#convert "${SOURCE}" -verbose -colors 256 -unique-colors -scale 1000% -alpha activate "${PTARGET}"
convert "${SOURCE}" -verbose -colors 256 -unique-colors -scale 1000% -type PaletteAlpha "${PTARGET}"

# FIXME: Getting return code from "convert" executable doesn't seem to
# work, so we check if palette exists.
test -f "${PTARGET}"
RET=$?
if [ "${RET}" -gt "0" ]; then
    echo
    echo "ERROR: Palette not created (error code: ${RET})"
    exit ${RET}
fi


# STEP 2: Create a transparent border buffer for trimming
# Arguments:
#   -bordercolor none: Makes transparent border
#   -border 5: Creates a 5px border (must be called AFTER -bordercolor)
convert "${PTARGET}" -verbose -bordercolor none -border 5 "${PTARGET}"

# FIXME: Currently does nothing here.
RET=$?
if [ "${RET}" -gt "0" ]; then
    echo
    echo "ERROR: Palette not created (error code: ${RET})"
    exit ${RET}
fi


# STEP 3: Trim all transparency & remove alpha channel
# Arguments:
#   -trim: Trims border pixels from image (in this case, transparent pixels)
#     (appears that alpha channel is removed with '-trim', but we call
#      '-alpha deactivate' just to be sure)
#   -alpha deactivate: Ensures that alpha channel is removed
convert "${PTARGET}" -verbose -trim -alpha deactivate "${PTARGET}"

# FIXME: Currently does nothing here.
RET=$?
if [ "${RET}" -gt "0" ]; then
    echo
    echo "ERROR: Palette not created (error code: ${RET})"
    exit ${RET}
fi


echo
echo "Done!"
