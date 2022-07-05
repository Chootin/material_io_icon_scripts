#! /bin/bash

# A script which synchronises meta files between identical file systems.
# Alec Tutin
# 2022-07-05

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

if [[ "$output_directory" == "" ]]; then
    echo "Output directory not specified!"
    exit 1
fi

if [[ "$output_directory" != */ ]]; then
    output_directory="$output_directory/"
fi

if [ ! -d "$input_directory" ]; then
    echo "Input directory does not exist: $input_directory"
    exit 1
fi

if [ ! -d "$output_directory" ]; then
    echo "Output directory does not exist: $output_directory"
    exit 1
fi

find $input_directory -name *.meta | while IFS= read -r meta_file; do
    output_file=${meta_file/"$input_directory"/"$output_directory"}
    output_file_path=`dirname $output_file`

    if [[ ! -d $output_file_path ]]; then
        echo "Directory does not exist! Unable to synchronise meta files..."
        echo "Some clean-up required."
        exit 1
    fi

    echo "Copying... $meta_file -> $output_file"
    cp $meta_file $output_file
done