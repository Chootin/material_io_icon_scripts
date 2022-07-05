#! /bin/bash

# A script which untangles the material.io icon folders into more managable ones.
# Alec Tutin
# 2022-07-04

# type_key to type_value
# materialicons - baseline
# materialiconsoutlined - outline
# materialiconsround - round
# materialiconssharp - sharp
# materialiconstwotone - twotone

# Current paths
# $base_input_path/$category/$icon/$type_key/$dp/$scalar/$type_value_$icon_$colour_$dp.png

# Desired output
# $base_output_path/$type_value/$category/$icon/$icon_$px.png

# DP to PX table
# 18dp/1x > 18px
# 18dp/2x > 36px
# 24dp/1x > 24px
# 24dp/2x > 48px
# 36dp/1x > DELETE
# 36dp/2x > 64px
# 48dp/1x > DELETE
# 48dp/2x > 96px

# Manually create a package in each of the final $type_value directories. The folders, names, (and perhaps meta files) should be the same otherwise.
# With the meta files the same, changing icon style should be as easy as swapping packages.

function move_file() {
    local category="$1"
    local icon="$2"
    local dp="$3"
    local scale="$4"
    local px="$5"

    local type_directory="$6"
    local type_prefix="$7"

    input_file="$input_directory$category/$icon/$type_directory/$dp/$scale/$type_prefix""_$icon""_$colour""_$dp.png"
    output_file="$output_directory$type_prefix/$category/$icon/$icon""_$px.png"
    echo "Moving file: $input_file -> $output_file"
    output_file_directory=`dirname $output_file`
    mkdir -p $output_file_directory
    cp $input_file $output_file
}

type_directories=("materialicons" "materialiconsoutlined" "materialiconsround" "materialiconssharp" "materialiconstwotone")
type_prefix_array=("baseline" "outline" "round" "sharp" "twotone")

dp_array=("18dp" "24dp" "36dp" "48dp")
px_1x_array=("18px" "24px" "36px" "48dp")
px_2x_array=("36px" "48px" "72px" "96px")

original_directory=`pwd`

input_directory="$original_directory"
output_directory=""
colour="black"

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
        -c|--colour)
            colour="$2"
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

cd $output_directory

for type in ${type_prefix[@]}; do
    echo "Creating icon type directory $type..."
    mkdir -p $type
done

cd $input_directory

for category in "./"*; do
    category=${category:2}

    if [ ! -d $category ]; then
        continue
    fi

    echo "Processing $category..."
    cd $category

    for icon in "./"*; do
        icon=${icon:2}

        if [ ! -d $icon ]; then
            continue
        fi

        echo "Found icon $icon..."
        for (( type_index=0; $type_index<${#type_directories[@]}; type_index++ )); do
            type_directory=${type_directories[$type_index]}
            type_prefix=${type_prefix_array[$type_index]}

            for (( size_index=0; $size_index<${#dp_array[@]}; size_index++ )); do
                dp=${dp_array[$size_index]}

                # Need to skip 36dp/1x and 48dp/1x as they are redundant
                if [ $dp != "36dp" ] && [ $dp != "48dp" ]; then
                    px_1x=${px_1x_array[$size_index]}

                    move_file $category $icon $dp "1x" $px_1x $type_directory $type_prefix
                fi

                px_2x=${px_2x_array[$size_index]}

                move_file $category $icon $dp "2x" $px_2x $type_directory $type_prefix
            done

        done
    done

    cd $input_directory
done

cd $original_directory
