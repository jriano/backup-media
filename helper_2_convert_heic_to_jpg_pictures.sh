#!/bin/bash

# Dependencies: imagemagick libheif1


DIRSFILE="dirs.json"
SOURCE=$( cat "${DIRSFILE}" | jq -r '.source' )

# Detect whether 'magick' or 'convert' is available
if command -v magick &>/dev/null; then
    CONVERT_CMD="magick convert"
elif command -v convert &>/dev/null; then
    CONVERT_CMD="convert"
else
    echo "Error: Neither 'magick' nor 'convert' commands are available. Please install ImageMagick."
    exit 1
fi

# Iterate through all .HEIC files
find "$SOURCE" -type f -name "*.HEIC" | while read -r heic_file; do
    # Construct the output .JPG file name
    jpg_file="$SOURCE/$(basename "${heic_file%.HEIC}.JPG")"

    # Save the original timestamps
    access_time=$(stat -c %x "$heic_file")
    modify_time=$(stat -c %y "$heic_file")
    create_time=$(stat -c %w "$heic_file" 2>/dev/null)
    
    echo "Converting: $heic_file -> $jpg_file"
    #if imagemagick convert "$heic_file" "$jpg_file"; then
    if $CONVERT_CMD "$heic_file" "$jpg_file"; then

        # Restore the timestamps to the new .JPG file
        touch -d "$modify_time" "$jpg_file"
        if [ -n "$create_time" ]; then
            touch -d "$create_time" "$jpg_file"
        fi

        rm "$heic_file"
    else
        echo "Conversion failed for: $heic_file"
    fi
done
