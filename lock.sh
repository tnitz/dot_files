#!/bin/bash

# i3lock blurred screen inspired by /u/patopop007 and the blog post
# http://plankenau.com/blog/post-10/gaussianlock

# Timings are on an Intel i7-2630QM @ 2.00GHz

# Dependencies:
# imagemagick
# i3lock
# scrot (optional but default)

IMAGE=/tmp/i3lock.png
SCREENSHOT="scrot $IMAGE" # 0.46s

# Get the screenshot, add the blur and lock the screen with it
$SCREENSHOT
convert $IMAGE -blur 0x2 -spread 4 $IMAGE
#mogrify -spread 4 $IMAGE
i3lock -i $IMAGE
rm $IMAGE
sleep 300; pgrep i3lock && xset dpms force off
