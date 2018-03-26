#!/bin/bash 

# Backup your pictures # By Juan C. Riano

# This script backups your JPG or JPEG pictures organizing them into folders by year and month.
# Folders are created only if they do not already exist.

# Dependencies: grep, awk, exif.

#PICSSOURCE=~/Dropbox/pics
#PICSDESTINATION='/media/jriano/T2/Familia-Riano-Fotos/'

PICSSOURCE="$1"
PICSDESTINATION="$2"
if ! [ -d "$PICSSOURCE" ]; then
    echo "Video source directory does not exist."
    exit 1
fi

if ! [ -d "$PICSDESTINATION" ]; then
    echo "Video destination directory does not exist."
    exit 1
fi
    

for file in $( find $PICSSOURCE -regextype posix-awk -iregex ".*\.(mp4|mpeg)$" )
do 
	echo "Backing up $file"
	WHOLESTR=$( exif $file | grep 'Date and Time' | grep 'Origi' )
	THEDATE=$( echo "$WHOLESTR" | awk '{split($0,arr,"|"); print arr[2]}' )
	THEYEAR=$( echo "$THEDATE" | awk '{split($0,arr,":"); print arr[1]}' )
	THEMONTH=$( echo "$THEDATE" | awk '{split($0,arr,":"); print arr[2]}' )

	if [[ "$THEYEAR" == "" ]]	# Is there exif info for this picture?
	then
		THEFOLDER="$PICSDESTINATION/no-date"	# Pictures with no exif info.
	else 
		THEFOLDER="$PICSDESTINATION/$THEYEAR-$THEMONTH"	# Folder in format yyyy-mm
	fi
	
	# Create folder, ignore if folder already exists, and copy files
	$( mkdir -p "$THEFOLDER")
	mv "$file" "$THEFOLDER"
	#cp --backup=numbered  "$file" "$THEFOLDER"
done
echo "Completed backing up videos."
