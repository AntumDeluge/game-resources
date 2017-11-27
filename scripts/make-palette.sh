#!/bin/sh

convert $1 -unique-colors -scale 1000%  palette-$1
