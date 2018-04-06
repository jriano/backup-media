rename_pic_if_exists() {
    # Accept parameter $file
    # $file is the name you want o use to save the file as

    local file_string
    local new_file_string

    file_string="$1"
    new_file_string="$1"

    if [ -f "$file_string" ]; then
        # File exists, then attach date to it and move on!

        local fpath
        local fbase
        local fpref
        local fext
        local date_string

        fpath=${file_string%/*}
        fbase=${file_string##*/}
        fpref=${fbase%.*}
        fext=${fbase##*.}

        fdate=$( date +"%Y%m%d-%H%M%S" )

        new_file_string="$fpath/$fpref_$fdate.fext"
    fi

    echo "$new_file_string"
}