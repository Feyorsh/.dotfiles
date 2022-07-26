rc=`<~/.config/yabai/yabairc`
lp_reg='left_padding[[:space:]]+0*([1-9]+)'
rp_reg='right_padding[[:space:]]+0*([1-9]+)'
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
if [[ $rc =~ $wg_reg ]]; then
	window_gap=$match[1]
else
	window_gap=0
fi

# something to note: this gets super fucked up if there's > 2 windows. idk if I really want to cover this edge case or not.

# checks should look like:
# if frame.x+frame.minwidth+right_padding>display_width-frame.x (if frame on right)
# if frame.x+frame.minwidth+left_padding>frame2.x (if frame on left)
read -r display_width display_height <<<`yabai -m query --displays --display | jq '\(.frame.w) \(.frame.h)'`
fixed_id=$1 # passed $YABAI_WINDOW_ID in yabairc 
read -r fixed_width fixed_height <<<`yabai -m query --windows --window $fixed_id | jq "\(.frame.w) \(.frame.h)"`
# ok, the problem here is that with > 2 'other' windows, the args to read become "id1 id2 width1 #IGNORED width2..." this should ideally grab the 'left most' window, or if the left space is partioned vertically, either window. (in this case min_width is actually max(minwidth1, minwidth2))
read -r bend_id bend_width bend_height <<<`yabai -m query --windows --space | jq '.[] | select(.id != $fixed_id) | "\(.id) \(.frame.w) \(.frame.h)"'`
# careful, as this only works if Spotify has basically been forced off the screen
((new_width = $bend_width-$display_width+$left_padding+$right_padding+$window_gap+$fixed_width))
yabai -m window $not_fixed --resize right:-$new_width:0
# it doesn't really fail per se, but just shrinks as much as it can. imo this is actually pretty good behaviour...leaves you at worst where you started. 
