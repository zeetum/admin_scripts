#!/bin/sh
echo "usage: png_to_jpg.sh <directory> <old_image_filename> <new_image_location>"
find ~/image_dir $1 -name $2 | sed 's/\(.*\)\/.*/\1/' | while read line
do
    rm $line"/"$2
    cp $3 $line
done
