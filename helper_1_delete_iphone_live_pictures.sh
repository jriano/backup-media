#!/bin/bash

# Dependencies: none

DIRSFILE="dirs.json"
SOURCE=$( cat "${DIRSFILE}" | jq -r '.source' )

# Enable case insensitive case matching
shopt -s nocasematch

# Find all .MOV files in the directory
find "$SOURCE" -type f -name "*.MOV" | while read -r mov_file; do
    # Get the corresponding .HEIC file by replacing the extension
    heic_file="${mov_file%.MOV}.HEIC"
    jpg_file="${mov_file%.MOV}.JPG"
    
    # Delete .MOV file if corresponding .HEIC file exists
    if [ -f "$heic_file" ]; then
        echo "Deleting: $mov_file (matched with $heic_file)"
        rm "$mov_file"
    fi

    # Delete .MOV file if corresponding .JPG file exists
    if [ -f "$jpg_file" ]; then
        echo "Deleting: $mov_file (matched with $jpg_file)"
        rm "$mov_file"
    fi
done
