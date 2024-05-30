#!/bin/bash

# Default time threshold in hours
DEFAULT_THRESHOLD="40hrs"

# Directory to clean, passed as the first argument, or default if not provided
DIR="${1:-/data/audios/folder}"
# Time threshold passed as the second argument, or default if not provided
TIME_THRESHOLD="${2:-$DEFAULT_THRESHOLD}"

# Check if the directory exists
if [ ! -d "$DIR" ]; then
  echo "Error: Directory $DIR does not exist."
  exit 1
fi

# Convert the time threshold into seconds
THRESHOLD_SECONDS=$(echo $TIME_THRESHOLD | sed 's/hrs$//')*3600

# Generate log file name
LOG_FILE="deleted-files-$(date +'%d-%m-%Y').log"

# Find and delete files, and log the details
find "$DIR" -name "*.wav" -type f -printf "%p\t%T+\n" | while IFS=$'\t' read -r file creation_time; do
    creation_timestamp=$(date -d "$creation_time" +%s)
    current_timestamp=$(date +%s)
    age=$((current_timestamp - creation_timestamp))
    if (( age > THRESHOLD_SECONDS )); then
        deletion_time=$(date --iso-8601=seconds)
        creation_time_iso=$(date -d "$creation_time" --iso-8601=seconds)
        echo -e "$file\t$creation_time_iso\t$deletion_time" >> "$LOG_FILE"
        rm "$file"
    fi
done
