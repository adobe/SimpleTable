#!/bin/bash

launchImagePath="$(dirname "$0")/Images.xcassets/LaunchImage.launchimage"
commonParameters="xc:white"

echo "Making launch images in $launchImagePath"

convert -size 640x960 $commonParameters "$launchImagePath/iphone@2x.png"
convert -size 640x1136 $commonParameters "$launchImagePath/iphone-retina4@2x.png"
convert -size 750x1334 $commonParameters "$launchImagePath/iphone-667h@2x.png"
convert -size 1242x2208 $commonParameters "$launchImagePath/iphone-736h@3x.png"
convert -size 768x1024 $commonParameters "$launchImagePath/ipad.png"
convert -size 1536x2048 $commonParameters "$launchImagePath/ipad@2x.png"
