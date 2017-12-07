#!/bin/sh

# Create Palette version 1.1
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


# Settings

# Number of columns per row
COLS=4


echo
echo "Directory: ${SDIR}"
echo "Source file: ${SNAME}"
echo "Palette file: ${PNAME}"
echo "Target file: ${PTARGET}"

echo
echo "Creating palette ..."
echo


# STEP 1: Create RGBA palette image.
# Arguments:
#   -define png:format=png32: Creates 32-bit RGBA PNG
#   -unique-colors: Create palette-like image
#   -scale 1000%: Creates 10x10 pixel tiles
#   -background none: Makes BG color transparent
#   -crop $((${COLS}*10))x10: COLS is number of columns per row
#   -append: Merge rows into a single image
convert -verbose "${SOURCE}" -define png:format=png32 -unique-colors -scale 1000% -background none -crop $((${COLS}*10))x10 -append "${PTARGET}"


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
# Notes:
#   - Automatically converted to indexed if colors less than 256.
convert -verbose "${PTARGET}" -bordercolor none -border 5 "${PTARGET}"

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
convert -verbose "${PTARGET}" -trim "${PTARGET}"

# FIXME: Currently does nothing here.
RET=$?
if [ "${RET}" -gt "0" ]; then
    echo
    echo "ERROR: Palette not created (error code: ${RET})"
    exit ${RET}
fi


echo
echo "Done!"
