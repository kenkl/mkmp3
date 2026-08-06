#!/usr/bin/env bash
# Sweep through a given directory structure and convert all .m4a files to .mp3 format using ffmpeg.
# The script also copies any existing .mp3 files to the output directory.

SOURCE_ROOT="${1:-.}"  # Source directory passed as the first argument (defaults to ".")
OUTPUT_DIR="$HOME/Desktop/mp3dump"                     # <-- Change this!

# Set the quality for transcoded MP3s
BITRATE="320k" 

echo "mkmp3 starting..."
echo "Source Root: $SOURCE_ROOT"
echo "Output Folder: $OUTPUT_DIR"

# 1. Check if the source directory exists
if [ ! -d "$SOURCE_ROOT" ]; then
    echo ""
    echo "ERROR: Source directory not found at '$SOURCE_ROOT'. Please check the path."
    exit 1
fi

# 2. Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"
if [ $? -ne 0 ]; then
    echo ""
    echo "FATAL ERROR: Could not create or access output directory '$OUTPUT_DIR'. Check permissions."
    exit 1
fi

# Counter for tracking progress
COUNT=0

# First pass: Find all .m4a files in the source directory and convert them to .mp3

echo -e "\nFirst pass: find/convert .m4a files..."

# Initialize empty arrays and starting time
m4a_files=()
convert_failures=()
copy_failures=()
start_time=$(date +"%H:%M:%S")
start_epoch=$(date +%s)

# Use find with -print0 to handle filenames with spaces or special characters safely.
# We use a while loop with IFS= and read -d '' to populate the array.
while IFS= read -r -d '' file; do
    m4a_files+=("$file")
done < <(find "$SOURCE_ROOT" -name "*.m4a" -print0)

# Verify the results, and exit if no .m4a files are found.
if [ ${#m4a_files[@]} -eq 0 ]; then
    echo "No .m4a files found. Moving on to second pass."
    skip_conversion=true
fi

if [ -z "$skip_conversion" ]; then
    echo "Found ${#m4a_files[@]} .m4a files to convert."
    for FULL_PATH in "${m4a_files[@]}"; do
        COUNT=$((COUNT + 1))

        # 1. Extract the filename without extension (e.g., "tracktitle")
        #    and use it as the base name for the output file.
        BASE_NAME="${FULL_PATH##*/}"
        FILENAME="${BASE_NAME%.*}"
        OUTPUT_FILE="$OUTPUT_DIR/$FILENAME.mp3"

        echo -e "\n[${COUNT}] Processing: $FULL_PATH"
        echo "       -> Outputting to: $OUTPUT_FILE"

        # 2. Perform the conversion using ffmpeg with additional flags for better compatibility and metadata handling.
        ffmpeg -i "$FULL_PATH" \
            -map 0 \
            -c:a libmp3lame \
            -q:a 2 \
            -id3v2_version 3 \
            -codec:v copy \
            -y \
            -loglevel error \
            "$OUTPUT_FILE"

        # Check if the last command failed (e.g., corrupted file, missing dependencies)
        if [ $? -ne 0 ]; then
            echo "!!! ERROR: Conversion failed for '$FULL_PATH'. Check log or format integrity."
            convert_failures+=("$FULL_PATH")
        fi
    done
fi 

# Second pass: Check for existing MP3 files in the output directory and copy them to the output directory.
echo -e "\nSecond pass: Just copy existing MP3 files to the output directory."

while IFS= read -r -d '' file; do
    mp3_files+=("$file")
done < <(find "$SOURCE_ROOT" -name "*.mp3" -print0)

# Verify the results, and exit if no .mp3 files are found.
if [ ${#mp3_files[@]} -eq 0 ]; then
    echo "No .mp3 files found."
fi

for FULL_PATH in "${mp3_files[@]}"; do
    COUNT=$((COUNT + 1))
    echo -e "\n[${COUNT}] Copying existing MP3: $FULL_PATH"
    cp -p "$FULL_PATH" "$OUTPUT_DIR/"
    if [ $? -ne 0 ]; then
        echo "!!! ERROR: Failed to copy '$FULL_PATH' to '$OUTPUT_DIR'. Check permissions."
        copy_failures+=("$FULL_PATH")
    fi   

done

echo -e "\nDone. Processed $COUNT Files."
echo "Start time: $start_time"
end_time=$(date +"%H:%M:%S")
end_epoch=$(date +%s)
echo "End time: $end_time"
echo "Duration: $((end_epoch - start_epoch)) seconds"

if [ ${#convert_failures[@]} -gt 0 ]; then
    echo -e "\n!!! Conversion failures detected:"
    for failed_file in "${convert_failures[@]}"; do
        echo "   - $failed_file"
    done
fi

if [ ${#copy_failures[@]} -gt 0 ]; then
    echo -e "\n!!! Copy failures detected:"
    for failed_file in "${copy_failures[@]}"; do
        echo "   - $failed_file"
    done
fi
