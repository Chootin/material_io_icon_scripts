#! /bin/bash

# A script aimed at converting black PNG files to white ones so we can multiply them by a colour to set their colour.
# Alec Tutin
# 2022-07-04

original_directory=`pwd`

input_directory="$original_directory"
output_directory=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--input)
            input_directory="$2"
            shift
            shift
            ;;
        -o|--ouput)
            output_directory="$2"
            shift
            shift
            ;;
        *)
            echo "Invalid argument: \"$1\""
            exit 1
    esac
done

if [[ "$input_directory" != */ ]]; then
    input_directory="$input_directory/"
fi

if [[ "$output_directory" != */ ]]; then
    output_directory="$output_directory/"
fi

if [ ! -d "$input_directory" ]; then
    echo "Input directory does not exist: $input_directory"
    exit 1
fi

if [ ! -d "$output_directory" ]; then
    echo "Creating output directory... $output_directory"
    mkdir -p "$output_directory"
fi

cd $input_directory

find . -name *.png | while IFS= read -r line; do
    input_subpath=${line:2}
    input_path="$input_directory$input_subpath"
    output_subpath=${input_subpath/"_black_"/"_white_"}
    output_path="$output_directory$output_subpath"

    echo "Converting -> $output_path"
    output_path_parent=`dirname $output_path`
    mkdir -p $output_path_parent
    convert $input_path -white-threshold "-1" $output_path
done

cd $original_directory