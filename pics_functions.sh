rename_pic_if_exists() {
    # Accept parameter $file
    # $file is the name you want o use to save the file as

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
        # File exists, rename it
        whole_string=$( exif "$existing_file" | grep 'Date and Time' | grep 'Origi' )
        the_date=$( echo "$whole_string" | awk '{split($0,arr,"|"); print arr[2]}' | awk -F'[: ]' '{print $1$2$3$4$5$6}' )
        the_date="$the_date"

        echo "prefix:"
        echo "$fprefix"

        new_file_name="$folder/$fprefix-$the_date.$fext"

        echo "File exists: $existing_file"
        echo "Renaming to $new_file_name"

        mv "$existing_file" "$new_file_name"
    fi
}