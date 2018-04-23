rename_pic_if_exists() {
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
    echo "prefix:"
    echo "$fprefix"
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

            echo "prefix:"
            echo "$fprefix"

            new_file_name="$folder/$fprefix-$the_date.$fext"

            echo "A File with the same name but different md5 sum exists."
            echo "Renaming existing file: $existing_file"
            echo "Renaming to $new_file_name"

            mv "$existing_file" "$new_file_name"
        fi
    fi
}