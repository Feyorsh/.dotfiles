#!/bin/zsh

cur=`yabai -m query --spaces --space | jq '.type'`

if [[ cur == "float" ]]; then
	yabai -m space --layout bsp
else
	yabai -m space --layout float
fi
