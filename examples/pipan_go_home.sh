#!/bin/bash
# calls pipan script to set home position

vert="0.13"
hori="0.2"
sh /home/pi/pi-blaster/pipan_set.sh "$vert" "$hori"
exit 0
