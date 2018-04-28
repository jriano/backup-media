#!/bin/bash

# Backup your pictures
#
# By Juan C. Riano
#
# This script backs up your images and videos organizing them into folders by year and month.
# Folders are created only if they do not already exist.
# Gets directories from dirs.json.
#
# Dependencies: grep, awk, rsync, exif, jq, stat.

#set -x

# Lets start working!
. pics_functions.sh
SOURCE=$( cat dirs.json | jq -r '.source' )
PICSDESTINATION=$( cat dirs.json | jq -r '.picsdestination' )
VIDSDESTINATION=$( cat dirs.json | jq -r '.vidsdestination' )


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
if [ ! -d "$SOURCE" ] || [ ! -w "$SOURCE" ]; then
    echo "Source directory does not exist or is not writable."
    exit 1
fi
if [ ! -d "$PICSDESTINATION" ] || [ ! -w "$PICSDESTINATION" ]; then
    echo "Pictures destination directory does not exist or is not writable."
    exit 1
fi
if [ ! -d "$VIDSDESTINATION" ] || [ ! -w "$VIDSDESTINATION" ]; then
    echo "Videos destination directory does not exist or is not writable."
    exit 1
fi

# Deal with spaces in names
OLD_IFS=$IFS
IFS=$'\n'

for file in $( find "$SOURCE" -type f -not -name ".*" )
do
	WHOLESTR=$( extract_info "$file" )
	ISMEDIA=$( echo "$WHOLESTR" | awk '{print $1}' )
	FILETYPE=$( echo "$WHOLESTR" | awk '{print $2}' )
	THEYEAR=$( echo "$WHOLESTR" | awk '{print $3}' )
	THEMONTH=$( echo "$WHOLESTR" | awk '{print $4}' )

	# If it is not a media file, then skip this file
	if [ "$ISMEDIA" == "other" ]; then
		# pass
		:
	fi

	# Save file in year/month directory
	if [ "$THEYEAR" == "no-date" ]; then
		if [ "$FILETYPE" == "image" ]; then
			THEFOLDER="$PICSDESTINATION/no-date"
		else
			THEFOLDER="$VIDSDESTINATION/no-date"
		fi
	else
		if [ "$FILETYPE" == "image" ]; then
			THEFOLDER="$PICSDESTINATION/$THEYEAR-$THEMONTH"	# Folder in format yyyy-mm
		else
			THEFOLDER="$VIDSDESTINATION/$THEYEAR-$THEMONTH"	# Folder in format yyyy-mm
		fi
	fi

	echo "Source File: $file"
	echo "string: $WHOLESTR"
	echo "File type:   $FILETYPE"
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