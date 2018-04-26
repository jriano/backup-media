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

# Lets start working!
. pics_functions.sh
PICSSOURCE=$( cat dirs.json | jq -r '.source' )
PICSDESTINATION=$( cat dirs.json | jq -r '.destination' )

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

# Deal with spaces in names
OLD_IFS=$IFS
IFS=$'\n'

for file in $( find "$PICSSOURCE" )
do
	WHOLESTR=$( extract_info "$file" )
	FILETYPE=$( echo "$WHOLESTR" | awk '{print $1}' )
	THEYEAR=$( echo "$WHOLESTR" | awk '{print $2}' )
	THEMONTH=$( echo "$WHOLESTR" | awk '{print $3}' )

	# I AM HERE RIGHT NOW

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
	rename_file_if_exists "$file" "$THEFOLDER"
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