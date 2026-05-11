#!/bin/bash

# Name of the output
OUTPUT="DP-1-9"

# Current resolution
CURRENT=$(xrandr --query | grep "^$OUTPUT" | grep -oP "\d+x\d+\+\d+\+\d+")

# Define resolutions
RES1="2560x1440"
RATE1="59.95"

RES2="3840x2160"
RATE2="29.97"

# Decide which mode to switch to
if [[ $CURRENT == "$RES1+"* ]]; then
    xrandr --output $OUTPUT --mode $RES2 --rate $RATE2
elif [[ $CURRENT == "$RES2+"* ]]; then
    xrandr --output $OUTPUT --mode $RES1 --rate $RATE1
else
    # If neither, default to RES1
    xrandr --output $OUTPUT --mode $RES1 --rate $RATE1
fi