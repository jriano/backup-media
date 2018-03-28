#!/bin/bash

# Backup your pictures
#
# By Juan C. Riano
#
# This script backs up your JPG or JPEG pictures organizing them into folders by year and month.
# Folders are created only if they do not already exist.
# Gets directories from dirs.json.
#
# Dependencies: grep, awk, rsync, exif, jq.

# set -x

# Make sure environment is proper
BLACKWHOLE=$( which exif )
if ! [ "$?" -eq "0"  ]; then
	echo "exif is missing, please install."
	exit 1
fi
BLACKWHOLE=$( which jq )
if ! [ "$?" -eq "0"  ]; then
	echo 'jq is missing, please install.'
	exit 1
fi
BLACKWHOLE=$( which rsync )
if ! [ "$?" -eq "0"  ]; then
	echo 'rsync is missing, please install.'
	exit 1
fi
if ! [ -f "./dirs.json" ]; then
	echo "json configuration file is missing."
	exit 1
fi
if [ ! -d "$PICSSOURCE" ] || [ ! -w "$PICSSOURCE" ]; then
    echo "Picture source directory does not exist or is not writable."
    exit 1
fi
if [ ! -d "$PICSDESTINATION" ] || [ ! -w "$PICSDESTINATION" ]; then
    echo "Picture destination directory does not exist or is not writable."
    exit 1
fi

# Lets start working!
PICSSOURCE=$( cat dirs.json | jq -r '.source' )
PICSDESTINATION=$( cat dirs.json | jq -r '.destination' )

# Deal with spaces in names
OLD_IFS=$IFS
IFS=$'\n'

for file in $( find "$PICSSOURCE" -regextype posix-awk -iregex ".*\.(jpeg|jpg)$" )
do
	WHOLESTR=$( exif "$file" | grep 'Date and Time' | grep 'Origi' )
	THEDATE=$( echo "$WHOLESTR" | awk '{split($0,arr,"|"); print arr[2]}' )
	THEYEAR=$( echo "$THEDATE" | awk '{split($0,arr,":"); print arr[1]}' )
	THEMONTH=$( echo "$THEDATE" | awk '{split($0,arr,":"); print arr[2]}' )

	if [[ "$THEYEAR" == "" ]]	# Is there exif info for this picture?
	then
		THEFOLDER="$PICSDESTINATION/no-date"	# Pictures with no exif info.
	else
		THEFOLDER="$PICSDESTINATION/$THEYEAR-$THEMONTH"	# Folder in format yyyy-mm
	fi

	echo "Source File: $file"
	echo "Destination: $THEFOLDER"

	# Create folder, ignore if folder already exists, and copy files
	$( mkdir -p "$THEFOLDER")
	#mv "$file" "$THEFOLDER"
	#cp --backup=numbered  "$file" "$THEFOLDER"
	rsync -hz "$file" "$THEFOLDER"
	if [ "$?" -eq "0" ]; then
		rm -rf "$file"
		echo "$file backed up and removed from source"
		echo ""
	else
		echo "Failed to backup $file"
		echo "Aborting copying, please check folder permissions."
		exit 1
	fi
done
echo "Completed backing up pictures."

# Restore IFS
IFS=$OLD_IFS