#!/usr/bin/env bash

PREVIOUS_STATE="None"
while true; do
	if [ "+$(playerctl -p spotify status 2> /dev/null)" = "+Playing" ]; then
		STATE="Playing"
	else
		STATE="Paused"
	fi
	if [ $STATE != $PREVIOUS_STATE ]; then
		if [ $STATE = "Playing" ]; then
			echo -e "{\"text\": \"\"}"
		else
			echo -e "{\"text\": \"\"}"
		fi
	fi
	sleep 0.2
	PREVIOUS_STATE=$STATE
done
