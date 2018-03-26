#!/bin/bash

TEMPMEDIAFOLDER="/home/jriano/temppicsfolder/"
SEAFOLDER="983f8a94-441c-4b5a-9a0d-186aa978e705"

#PICSDESTINATION="/media/jriano/T2/Familia-Riano-Fotos/"
#VIDSDESTINATION="/media/jriano/T2/Familia-Riano-Videos/"
UNSORTED="$PICSDESTINATION/to-sort/"


PICSDESTINATION="/home/jriano/t2pics/"
VIDSDESTINATION="/home/jriano/t2vids/"

SEALIBRARY="983f8a94-441c-4b5a-9a0d-186aa978e705"
SEASERVER="http://127.0.0.1:8000" 

# First check if folders are available, otherwise quit
if ! [ -d "$PICSDESTINATION" ]; then
    echo "Pics destination folder does not exist"
    exit 1
fi

if ! [ -d "$VIDSDESTINATION" ]; then
    echo "Vids destination folder does not exist"
    exit 1
fi

# Create temp folder if it does not exist
mkdir -p "$TEMPMEDIAFOLDER"

# Download files from Sea server
seaf-cli download -l $SEALIBRARY -s $SEASERVER -d $TEMPMEDIAFOLDER -u juan.riano@gmail -p misfoticos87

# Backup pictures
./backup_your_pictures.sh "$TEMPMEDIAFOLDER" "$PICSDESTINATION"

# Backup videos
./backup_your_videos.sh "$TEMPMEDIAFOLDER" "$VIDSDESTINATION"

# Move any other left files into the backup drive
mkdir -p "$UNSORTED"
for file in $( find "$TEMPMEDIAFOLDER" )
do
    mv "$file" "$UNSORTED"
done
