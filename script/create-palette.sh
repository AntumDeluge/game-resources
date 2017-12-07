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
COLS="${COLS:-12}"

# Force quantization
FQUANT="${FQUANT:-0}"

# Max number of colors for quantization
COLORS="${COLORS:-256}"


echo
echo "Directory: ${SDIR}"
echo "Source file: ${SNAME}"
echo "Palette file: ${PNAME}"
echo "Target file: ${PTARGET}"

echo
echo "Copying image ..."
echo

cp -v "${SOURCE}" "${PTARGET}"
RET=$?
if [ "${RET}" -gt "0" ]; then
    echo
    echo "ERROR: Could not copy image (error code: ${RET})"
    echo "Exiting ..."
    exit ${RET}
fi

echo
echo "Creating palette ..."
echo


if [ "${FQUANT}" -gt "0" ]; then
    echo
    echo "Reducing image colors to ${COLORS} ..."

    convert -verbose "${PTARGET}" -colors ${COLORS} "${PTARGET}"
fi

RET=$?
if [ "${RET}" -gt "0" ]; then
    echo
    echo "ERROR: convert returned error code ${RET}"
    echo "Exiting ..."
    exit ${RET}
fi


# Create RGBA palette image.
# Arguments:
#   -alpha Off: Seems to add one more color (FIXME: should be checked agains "On" for accuracty).
#   -define png:format=png32: Creates 32-bit RGBA PNG
#   -unique-colors: Create palette-like image
#   -scale 1000%: Creates 10x10 pixel tiles
#   -background none: Makes BG color transparent
#   -crop $((${COLS}*10))x10: COLS is number of columns per row
#   -append: Merge rows into a single image
convert -verbose "${PTARGET}" -alpha Off -define png:format=png32 -unique-colors -scale 1000% -background none -crop $((${COLS}*10))x10 -append "${PTARGET}"

RET=$?
if [ "${RET}" -gt "0" ]; then
    echo
    echo "ERROR: convert returned error code ${RET}"
    echo "Exiting ..."
    exit ${RET}
fi


# Create a transparent border buffer for trimming
# Arguments:
#   -bordercolor none: Makes transparent border
#   -border 5: Creates a 5px border (must be called AFTER -bordercolor)
# Notes:
#   - Automatically converted to indexed if colors less than 256.
convert -verbose "${PTARGET}" -background none -bordercolor none -border 5 "${PTARGET}"

RET=$?
if [ "${RET}" -gt "0" ]; then
    echo
    echo "ERROR: convert returned error code ${RET}"
    echo "Exiting ..."
    exit ${RET}
fi


# Trim all transparency & remove alpha channel
# Arguments:
#   -trim: Trims border pixels from image (in this case, transparent pixels)
#convert -verbose "${PTARGET}" -trim "${PTARGET}"

RET=$?
if [ "${RET}" -gt "0" ]; then
    echo
    echo "ERROR: convert returned error code ${RET}"
    echo "Exiting ..."
    exit ${RET}
fi


echo
echo "Done!"
