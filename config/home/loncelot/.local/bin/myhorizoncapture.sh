#!/bin/bash

if wmctrl -l | grep "evt"; then
    mywin.sh --max "evt";
    mywin.sh --click "evt";
fi
