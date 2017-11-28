!/bin/sh
echo "usage: replace_img.sh <directory> <old_image_filename> <new_image_location>
e.g.
    ./replace_img.sh ~/www/pictures old_image.png ~/www/new_picture.jpg"

find $1 -name $2 | sed 's/\(.*\)\/.*/\1/' | while read line
do
    rm $line"/"$2
    cp $3 $line
done
