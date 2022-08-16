#!/usr/bin/zsh

# args:
# $1: $YABAI_WINDOW_ID of chonky window
# $2: min_width of chonky window
# $3: min_height of chonky window

fixed_id=$1
fixed_minwidth=$2
fixed_minheight=$3
rc=`<~/.config/yabai/yabairc`

lp_reg='left_padding[[:space:]]+0*([1-9]+)'
rp_reg='right_padding[[:space:]]+0*([1-9]+)'
bp_reg='bottom_padding[[:space:]]+0*([1-9]+)'
tp_reg='top_padding[[:space:]]+0*([1-9]+)'
wg_reg='window_gap[[:space:]]+0*([1-9]+)'
if [[ $rc =~ $lp_reg ]]; then
	left_padding=$match[1]
else
	left_padding=0
fi
if [[ $rc =~ $rp_reg ]]; then
	right_padding=$match[1]
else
	right_padding=0
fi
if [[ $rc =~ $bp_reg ]]; then
	bottom_padding=$match[1]
else
	bottom_padding=0
fi
if [[ $rc =~ $tp_reg ]]; then
	top_padding=$match[1]
else
	top_padding=0
fi
if [[ $rc =~ $wg_reg ]]; then
	window_gap=$match[1]
else
	window_gap=0
fi

# something to note: this gets super fucked up if there's > 2 windows. idk if I really want to cover this edge case or not.

read -r display_width display_height <<<`yabai -m query --displays --display | jq '\(.frame.w) \(.frame.h)'`
read -r fixed_width fixed_height fixed_x fixed_y <<<`yabai -m query --windows --window $fixed_id | jq "\(.frame.w) \(.frame.h) \(.frame.x) \(.frame.y)"`
# this should ideally grab the 'left most' window, or if the left space is partioned vertically, either window. (in this case min_width is actually max(minwidth1, minwidth2))
# we'll go by max id, cause it's the only guaranteed unique thing.
read -r bend_id bend_width bend_height bend_x bend_y <<<`yabai -m query --windows --space | jq '.[] | select(.id != $fixed_id && .frame.x != fixed_x) | max_by(.id) | "\(.id) \(.frame.w) \(.frame.h) \(.frame.x) \(.frame.y)"'`

# checks should look like:
# if frame.x+frame.minwidth+right_padding>display_width(if frame on right)
# if frame.x+frame.minwidth+window_gap>frame2.x (if frame on left)
((new_width = $bend_width-$display_width+$left_padding+$right_padding+$window_gap+$fixed_width))
if [[ fixed_x > bend_x ]]; then
	if [[ fixed_x + fixed_minwidth + right_padding > display_width ]]; then
		yabai -m window $not_fixed --resize right:-$new_width:0
	fi
elif [[ fixed_x < bend_x ]]; then
	if [[ fixed_x + fixed_minwidth + window_gap > bend_x ]]; then
		yabai -m window $not_fixed --resize left:-$new_width:0
	fi
fi
# we'll implement this so it gets 2 rounds; also helps if fixed is in a corner

# Spotify is on the bottom:
# if fixed_y + fixed_minheight + bottom_padding > display_height
((new_height = $bend_height-$display_height+$bottom_padding+$top_padding+$window_gap+$fixed_height))
if [[ fixed_y > bend_y ]]; then
	if [[ fixed_y + fixed_minheight + bottom_padding > display_height ]]; then
		yabai -m window $not_fixed --resize bottom:-$new_height:0
elif [[ fixed_y < bend_y ]]; then
	if [[ fixed_y + fixed_minheight + window_gap > bend_y ]]; then
		yabai -m window $not_fixed --resize top:-$new_height:0

# it doesn't really fail per se, but just shrinks as much as it can. imo this is actually pretty good behaviour...leaves you at worst where you started. 
