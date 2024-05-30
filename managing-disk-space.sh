#!/bin/bash

# Default time threshold in hours
DEFAULT_THRESHOLD="40hrs"
THRESHOLD=${1:-$DEFAULT_THRESHOLD}

# Convert the threshold to seconds
THRESHOLD_SECONDS=$(echo $THRESHOLD | sed 's/hrs/*3600/' | bc)

# Get the current date for the log file name
CURRENT_DATE=$(date +"%d-%m-%Y")

# Log file
LOG_FILE="deleted-files-${CURRENT_DATE}.log"

# Directory containing audio files
AUDIO_DIR="/data/audios/folder"

# Find and delete files older than the specified threshold
find $AUDIO_DIR -name "*.wav" -type f -printf "%p %T@ %Tc\n" | while read FILE CREATETIME CREATETIME_HUMAN
do
  CURRENT_TIME=$(date +%s)
  AGE=$((CURRENT_TIME - $(echo $CREATETIME | cut -d. -f1)))
  if [ $AGE -ge $THRESHOLD_SECONDS ]; then
    # Log the deletion details
    DELETION_TIME=$(date -Iseconds)
    echo "$FILE $CREATETIME_HUMAN $DELETION_TIME" >> $LOG_FILE
    # Delete the file
    rm "$FILE"
  fi
done
