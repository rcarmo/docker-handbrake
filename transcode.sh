#!/bin/bash

shopt -s nullglob

if [ -z "${EXTENSION}" ]; then 
   EXTENSION=mkv
fi

if [ -z "${AUDIO_CODEC}" ]; then 
   AUDIO_CODEC=AAC
fi

if [ -z "${VIDEO_CODEC}" ]; then 
   VIDEO_CODEC=H.265
fi

export WORKDIR="$PWD"

encode_file () {
    export TARGET="${FILE%.$EXTENSION}.mp4"
    export MARKER="${FILE%.$EXTENSION}.lock"
    export LOGFILE="$WORKDIR/${FILE%.$EXTENSION}.log"
    export METADATA="${FILE%.$EXTENSION}.nfo"
    if [ "$PAUSES" != "false" ]; then 
       # Pause before check
       sleep 5
       sleep $((RANDOM % 11))
    fi
    if [ ! -f "$MARKER" ]; then
        echo "====> Processing $FILE" >> "$LOGFILE"
        echo "$HOSTNAME" > "$MARKER"
        if [ ! -z "$SCRATCH_FOLDER" ]; then
            echo "====> Copying $FILE to $SCRATCH_FOLDER" >> "$LOGFILE"
            cp "$FILE" "$SCRATCH_FOLDER/$FILE"
            cd "$SCRATCH_FOLDER"
        fi
        echo "====> Currently in $PWD" >> "$LOGFILE"
        echo "====> Transcoding $FILE -> $TARGET" >> "$LOGFILE" 
        if [ "$VIDEO_CODEC" == "H.264" ]; then
            if [ "$AUDIO_CODEC" == "AAC" ]; then
                stdbuf -oL -eL HandBrakeCLI -i "$FILE" -o "$TARGET" -E faac -B 96k -6 stereo -R 44.1 -e x264 -q 27 -x cabac=1:ref=5:analyse=0x133:me=umh:subme=9:chroma-me=1:deadzone-inter=21:deadzone-intra=11:b-adapt=2:rc-lookahead=60:vbv-maxrate=10000:vbv-bufsize=10000:qpmax=69:bframes=5:b-adapt=2:direct=auto:crf-max=51:weightp=2:merange=24:chroma-qp-offset=-1:sync-lookahead=2:psy-rd=1.00,0.15:trellis=2:min-keyint=23:partitions=all -s "1,2,3,4,5,6" -m 2>> "$LOGFILE"  
            else
                stdbuf -oL -eL HandBrakeCLI -i "$FILE" -o "$TARGET" -E ac3 -B 448k -6 5point1 -R 48 -e x264 -q 27 -x cabac=1:ref=5:analyse=0x133:me=umh:subme=9:chroma-me=1:deadzone-inter=21:deadzone-intra=11:b-adapt=2:rc-lookahead=60:vbv-maxrate=10000:vbv-bufsize=10000:qpmax=69:bframes=5:b-adapt=2:direct=auto:crf-max=51:weightp=2:merange=24:chroma-qp-offset=-1:sync-lookahead=2:psy-rd=1.00,0.15:trellis=2:min-keyint=23:partitions=all -s "1,2,3,4,5,6" -m 2>> "$LOGFILE"
            fi
        else
            if [ "$AUDIO_CODEC" == "AAC" ]; then
                stdbuf -oL -eL HandBrakeCLI -i "$FILE" -o "$TARGET" --preset-import-file /h265aac.json --preset "H.265 MP4" -m 2>> "$LOGFILE"
            else
                stdbuf -oL -eL HandBrakeCLI -i "$FILE" -o "$TARGET" --preset-import-file /h265ac3.json --preset "H.265 MP4" -m 2>> "$LOGFILE"
            fi
        fi
        if [ $? -eq 0 ]; then
            if [ ! -z "$SCRATCH_FOLDER" ]; then
                echo "====> Removing original file in $SCRATCH_FOLDER" >> "$LOGFILE"
                rm -f "$SCRATCH_FOLDER/$FILE"
                echo "====> Moving new file $TARGET to $WORKDIR" >> "$LOGFILE"
                mv "$SCRATCH_FOLDER/$TARGET" "$WORKDIR/$TARGET"
            fi
            echo "====> Transcoding successful, removing $FILE" >> "$LOGFILE"
            rm -f "$WORKDIR/$FILE"
        fi
        cd "$WORKDIR"
        echo "====> Removing lock and old metadata inside $PWD" >> "$LOGFILE"
        rm -f "$MARKER"
        rm -f "$METADATA" # remove old Plex metadata
        echo "====> Done encoding $FILE" >> "$LOGFILE"
    fi
}

if [ "$RANDOM_PICK" = true ]; then
    ls *.$EXTENSION | shuf | while read FILE; do 
        encode_file
    done
else
    for FILE in *.$EXTENSION; do
        encode_file
    done
fi
