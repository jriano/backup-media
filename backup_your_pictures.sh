#!/bin/bash

# Backup your pictures # By Juan C. Riano

# This script backups your JPG or JPEG pictures organizing them into folders by year and month.
# Folders are created only if they do not already exist.

# Dependencies: grep, awk, exif, jq.


# Get directories from dirs.json
#PICSSOURCE=~/Dropbox/pics
#PICSDESTINATION='/media/jriano/T2/Familia-Riano-Fotos/'

PICSSOURCE=$( cat dirs.json | jq -r '.source' )
PICSDESTINATION=$( cat dirs.json | jq -r '.destination' )

if ! [ -f "./dirs.json" ]; then
	echo "json configuration file is missing."
	exit 1
fi

if ! [ -d "$PICSSOURCE" ]; then
    echo "Picture source directory does not exist."
    exit 1
fi

if ! [ -d "$PICSDESTINATION" ]; then
    echo "Picture destination directory does not exist."
    exit 1
fi

if [ -z $( which exif ) ]; then
	echo "exif is missing, please install."
	exit 1
fi

if [ -z $( which jq ) ]; then
	echo 'jq is missing, please install.'
	exit 1
fi


for file in $( find $PICSSOURCE -regextype posix-awk -iregex ".*\.(jpeg|jpg)$" )
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
echo "Completed backing up pictures."
