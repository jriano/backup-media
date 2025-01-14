#!/bin/bash

# Dependencies: imagemagick libheif1


DIRSFILE="dirs.json"
SOURCE=$( cat "${DIRSFILE}" | jq -r '.source' )

# Iterate through all .HEIC files
find "$SOURCE" -type f -name "*.HEIC" | while read -r heic_file; do
    # Construct the output .JPG file name
    jpg_file="$SOURCE/$(basename "${heic_file%.HEIC}.JPG")"
    
    echo "Converting: $heic_file -> $jpg_file"
    if magick convert "$heic_file" "$jpg_file"; then
        echo "Conversion successful. Deleting: $heic_file"
        rm "$heic_file"
    else
        echo "Conversion failed for: $heic_file"
    fi
done
