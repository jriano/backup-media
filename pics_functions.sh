rename_pic_if_exists() {
    # Accept parameter $file
    # $file is the name you want o use to save the file as

    local file_string
    local folder

    local fpath
    local fbase
    local fpref
    local fext
    local existing_file
    local new_file_name
    local whole_string
    local the_date

    file_string="$1"
    folder="$2"

    fpath=${file_string%/*}
    fbase=${file_string##*/}
    fpref=${fbase%.*}
    fext=${fbase##*.}

    existing_file="$folder/$fbase"

    if [ -f "$existing_file" ]; then
        # File exists, rename it
        whole_string=$( exif "$existing_file" | grep 'Date and Time' | grep 'Origi' )
        the_date=$( echo "$whole_string" | awk '{split($0,arr,"|"); print arr[2]}' | awk -F'[: ]' '{print $1$2$3$4$5$6}' )

        new_file_name="$folder/$fpref_$the_date.$fext"

        echo "File exists: $file_string"
        echo "Renaming to $new_file_name"

        mv "$file_string" "$new_file_name"
}