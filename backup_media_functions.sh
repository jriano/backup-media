rename_file_if_exists() {
    # Requires 2 parameters:
    # $file         <== The name of the file bo backup
    # $THEFOLDER    <== Where the file will be backedup
    #
    # If the file name is already present in the folder, an md5 checksum is done,
    # if they are different, the existing file is renamed.
    # If the sums match, nothing is done.

    #set -x

    local file_to_backup
    local folder

    local fpath
    local fbase
    local fprefix
    local fext
    local existing_file
    local new_file_name
    local whole_string
    local the_date

    file_to_backup="$1"
    folder="$2"

    fpath=${file_to_backup%/*}
    fbase=${file_to_backup##*/}
    fprefix=${fbase%.*}
    fext=${fbase##*.}

    existing_file="$folder/$fbase"

    if [ -f "$existing_file" ]; then
        # File exists, rename it only if md5 checksums are different, otherwise just skip over it
        sum_existing_file=$( md5sum $existing_file | awk '{print $1}' )
        sum_file_to_backup=$( md5sum $file_to_backup | awk '{print $1}' )

        if [ "$sum_existing_file" != "$sum_file_to_backup" ]; then
            whole_string=$( exif "$existing_file" | grep 'Date and Time' | grep 'Origi' )
            the_date=$( echo "$whole_string" | awk '{split($0,arr,"|"); print arr[2]}' | awk -F'[: ]' '{print $1$2$3$4$5$6}' )
            the_date="$the_date"

            echo "prefix: $fprefix"

            new_file_name="$folder/$fprefix-$the_date.$fext"

            echo "A File with the same name but different md5 sum exists."
            echo "Renaming existing file: $existing_file"
            echo "Renaming to $new_file_name"

            mv "$existing_file" "$new_file_name"
        fi
    fi
}

extract_info() {
    # Requires 1 parameter (file name with patch)
    #
    # Returns a string with the following info
    # "media/other filetype YYYY MM"
    # where the first word (media/other) is used to identify if the file is pics/vids,
    # the second, filetype clarifies exactely by saying "video" or "image"

    local file_name

    local file_ext
    local file_type
    local whole_string
    local file_date
    local file_year
    local file_month
    local has_exif
    local tool_used
    local return_string

    file_name=$1

    # file type can be image, video, text, ...
    # file -b   # so that file name which may have "media" is not prepend
    # file_type=$( file -b $file_name | grep -iE 'media|video|stream' )
    # if [ -z "$file_type" ]; then
    #     file_type=$( file -b $file_name | grep -iE 'image' )
    #     if [ -z "$file_type" ]; then
    #         file_type="other"
    #     else
    #         file_type="image"
    #     fi
    # else
    #     file_type="video"
    # fi



    # file type can be image, video, text, ...
    # file -b   # so that file name which may have "media" is not prepend
    file_type=$( file -b --mime-type $file_name | awk -F'/' '{print $1}' )

    # Deal with special file types not handled well by 'file'
    file_ext=$( echo "$file_name" | grep -oE "(.[a-zA-Z0-9]{3})$" )
    VIDEO_TYPES=".MTS"
    file_test=$( echo "$VIDEO_TYPES" | grep "$file_ext" )
    if ! [ -z "$file_test" ]; then
        file_type="video"
    fi


    if [ "$file_type" == "video" ] || [ "$file_type" == "image" ] || [ "$file_type" == "audio" ] ; then
        # Check if file has exif information
        has_exif=$( exif $file_name 2>&1 | awk 'NR==1{print $1}' )
        if ! [ "$has_exif" == "Corrupt" ]; then
            # Have exif, use it!
            whole_string=$( exif "$file_name" | grep 'Date and Time' | grep 'Origi' )
            file_date=$( echo "$whole_string" | awk -F'|' '{print $2}' | awk '{print $1}' )
            file_year=$( echo "$file_date" | awk -F':' '{print $1}' )
            file_month=$( echo "$file_date" | awk -F':' '{print $2}' )
            tool_used="exif"
        else
            # Does not have exif
            file_date=$( stat "$file_name" | grep Modify | awk '{print $2}' )
            file_year=$( echo "$file_date" | awk -F'-' '{print $1}' )
            file_month=$( echo "$file_date" | awk -F'-' '{print $2}' )
            tool_used="stat"
        fi
        if [ "$file_year" == "" ] || [ "$file_month" == "" ]; then
            file_year="no-date"
            file_month="no-date"
        fi
        return_string="media $file_type $file_year $file_month $tool_used"
    else
        # Test for special known cases
        # Don't do anything, just return "skip filetype"
        return_string="other $file_type"
    fi

    echo "$return_string"
}